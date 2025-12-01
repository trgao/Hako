//
//  NetworkManager.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import AuthenticationServices
import KeychainAccess
import FeedKit

@MainActor
class NetworkManager: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    @Published var isSignedIn = false
    @Published var user: User?
    static var shared = NetworkManager()
    
    // Caches
    let imageCache = NSCache<NSString, ImageCache>()
    var imageUrlMap = ThreadSafeDictionary<String, String>()
    
    let animeCache = ItemCache<Int, Anime>()
    let animeNextEpisodeCache = ItemCache<Int, NextAiringEpisode?>()
    let animeCharactersCache = ItemCache<Int, [ListCharacter]>()
    let animeStaffsCache = ItemCache<Int, [Staff]>()
    let animeRelatedCache = ItemCache<Int, [RelatedItem]>()
    
    let mangaCache = ItemCache<Int, Manga>()
    let mangaCharactersCache = ItemCache<Int, [ListCharacter]>()
    let mangaAuthorsCache = ItemCache<Int, [Author]>()
    let mangaRelatedCache = ItemCache<Int, [RelatedItem]>()
    
    let characterCache = ItemCache<Int, Character>()
    let personCache = ItemCache<Int, Person>()
    
    // API base urls
    private let jikanBaseApi = "https://api.jikan.moe/v4"
    private let malBaseApi = "https://api.myanimelist.net/v2"
    private let anilistBaseApi = "https://graphql.anilist.co"
    
    // Fields for MAL API
    private let animeFields = "alternative_titles,start_date,end_date,synopsis,mean,rank,popularity,media_type,status,genres,my_list_status,num_episodes,start_season,broadcast,source,average_episode_duration,rating,studios,opening_themes,ending_themes,videos,pictures,recommendations{alternative_titles,start_date,end_date,synopsis,mean,rank,popularity,media_type,status,genres,my_list_status,num_episodes,start_season,broadcast,source,average_episode_duration,rating,studios,opening_themes,ending_themes,videos,pictures,num_list_users,list_status},num_list_users,list_status"
    private let mangaFields = "alternative_titles,start_date,end_date,synopsis,mean,rank,popularity,media_type,status,genres,my_list_status,num_volumes,num_chapters,authors{first_name,last_name},serialization,pictures,recommendations{alternative_titles,start_date,end_date,synopsis,mean,rank,popularity,media_type,status,genres,my_list_status,num_volumes,num_chapters,authors{first_name,last_name},serialization,pictures,num_list_users,list_status},num_list_users,list_status"
    
    // API token bucket rate limiting
    private let malBucket = TokenBucket(capacity: 2, refillRate: 1)
    private let jikanBucket = TokenBucket(capacity: 2, refillRate: 1)
    private let anilistBucket = TokenBucket(capacity: 90, refillRate: 1)
    
    private let decoder: JSONDecoder
    private let clientId = Bundle.main.infoDictionary?["API_CLIENT_ID"] as! String
    private let keychain = Keychain(service: "mal-api")
    private let dateFormatter = ISO8601DateFormatter()
    
    override init() {
        // JSON Decoder
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            let len = dateStr.count
            var date: Date? = nil
            let yearOnlyFormatter = DateFormatter()
            yearOnlyFormatter.dateFormat = "yyyy"
            yearOnlyFormatter.locale = Locale(identifier: "en_US_POSIX")
            yearOnlyFormatter.timeZone = TimeZone(secondsFromGMT: 3600)
            let monthOnlyFormatter = DateFormatter()
            monthOnlyFormatter.dateFormat = "yyyy-MM"
            let normalDateFormatter = DateFormatter()
            normalDateFormatter.dateFormat = "yyyy-MM-dd"
            let iso8601DateFormatter = ISO8601DateFormatter()
            if len == 4 {
                date = yearOnlyFormatter.date(from: dateStr)
            } else if len == 7 {
                date = monthOnlyFormatter.date(from: dateStr)
            } else if len == 10 {
                date = normalDateFormatter.date(from: dateStr)
            } else {
                date = iso8601DateFormatter.date(from: dateStr)
            }
            guard let date_ = date else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateStr)")
            }
            return date_
        })
        
        super.init()
        
        // Check if user is currently signed in and retrieve user profile
        Task {
            if keychain["accessToken"] != nil, let name = UserDefaults.standard.string(forKey: "name") {
                self.isSignedIn = true
                print("Currently logged in")
                
                self.user = User(name: name, joinedAt: UserDefaults.standard.string(forKey: "joinedAt"), picture: UserDefaults.standard.string(forKey: "picture"))
                _ = await downloadImage(id: "userImage", imageUrl: UserDefaults.standard.string(forKey: "picture"))
            }
        }
    }
    
    // Generic MALApi request
    private func sendMALRequest<T: Decodable>(url: URL, method: String, body: Data? = nil, token: String? = nil, _ contentType: String? = nil, _ retries: Int = 3) async throws -> T {
        if retries == 0 {
            signOut()
            throw NetworkError.outOfRetries
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let contentType = contentType {
            request.setValue(contentType, forHTTPHeaderField:"Content-Type")
        }
        if let body = body {
            request.httpBody = body
        }
        
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "X-MAL-CLIENT-ID": clientId
        ]
        var hasToken = false
        if let token = keychain["accessToken"] ?? token {
            config.httpAdditionalHeaders?["Authorization"] = "Bearer \(token)"
            hasToken = true
        }
        let session = URLSession(configuration: config)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badResponse
        }
        
        if httpResponse.statusCode == 401 && hasToken {
            try await refreshToken()
            let result: T = try await sendMALRequest(url: url, method: method, body: body, token: token, contentType, retries - 1)
            return result
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 404 {
                throw NetworkError.notFound
            } else {
                throw NetworkError.badStatusCode(httpResponse.statusCode)
            }
        }
        
        do {
            var decoded: T
            if data.isEmpty {
                decoded = try decoder.decode(T.self, from: Data())
            } else {
                decoded = try decoder.decode(T.self, from: data)
            }
            return decoded
        } catch {
            throw NetworkError.jsonParseFailure
        }
    }
    
    // Get access token when user is signing in for the first time
    private func getAccessToken(_ code: String, _ codeVerifier: String) async throws -> String {
        let url = URL(string: "https://myanimelist.net/v1/oauth2/token")!
        let parameters: Data = "client_id=\(clientId)&code=\(code)&code_verifier=\(codeVerifier)&grant_type=authorization_code".data(using: .utf8)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpBody = parameters
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badStatusCode(httpResponse.statusCode)
        }
        
        do {
            let responseObject = try decoder.decode(MALAuthenticationResponse.self, from: data)
            print(responseObject)
            self.keychain["accessToken"] = responseObject.accessToken
            self.keychain["refreshToken"] = responseObject.refreshToken
            return responseObject.accessToken
        } catch {
            throw NetworkError.jsonParseFailure
        }
    }
    
    // Refresh access token using stored refresh token
    private func refreshToken() async throws {
        guard let token = keychain["refreshToken"] else {
            throw NetworkError.invalidRefreshToken
        }
        let url = URL(string: "https://myanimelist.net/v1/oauth2/token")!
        let parameters: Data = "client_id=\(clientId)&grant_type=refresh_token&refresh_token=\(token)".data(using: .utf8)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpBody = parameters

        let (data, response) = try await URLSession.shared.data(for: request)
            
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badResponse
        }
            
        guard httpResponse.statusCode != 403 else {
            throw NetworkError.invalidRefreshToken
        }
            
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badStatusCode(httpResponse.statusCode)
        }
            
        do {
            let responseObject = try decoder.decode(MALAuthenticationResponse.self, from: data)
            self.keychain["accessToken"] = responseObject.accessToken
            self.keychain["refreshToken"] = responseObject.refreshToken
        } catch {
            throw NetworkError.jsonParseFailure
        }
    }
    
    // Sign in function with old completion handler syntax
    private func signInWithCompletion(_ pkce: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        let session = ASWebAuthenticationSession(url: URL(string: "https://myanimelist.net/v1/oauth2/authorize?response_type=code&client_id=\(clientId)&code_challenge=\(pkce)")!, callbackURLScheme: "hako") { callbackURL, error in
            if let error = error {
                completion(.failure(.unknownError(error)))
                return
            }

            if let callbackURL = callbackURL {
                if let urlComponents = URLComponents(url: callbackURL, resolvingAgainstBaseURL: true), let items = urlComponents.queryItems, let token = items[0].value {
                    completion(.success(token))
                }
            } else {
                completion(.failure(.badResponse))
            }
        }
        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = true
        session.start()
    }
    
    // Sign in user (async wrapper for signInWithCompletion)
    func signIn() async throws {
        let pkce = PKCE.generateCodeVerifier()
        let token = try await withCheckedThrowingContinuation { continuation in
            signInWithCompletion(pkce) { result in
                switch result {
                case .success(let token):
                    continuation.resume(returning: token)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
        let accessToken = try await getAccessToken(token, pkce)
        self.isSignedIn = true
        try await getUserProfile(accessToken)
    }

    // Sign out user
    func signOut() {
        self.isSignedIn = false
        self.keychain["accessToken"] = nil
        self.keychain["refreshToken"] = nil
        UserDefaults.standard.set(nil, forKey: "name")
        UserDefaults.standard.set(nil, forKey: "joinedAt")
        UserDefaults.standard.set(nil, forKey: "picture")
        UserDefaults.standard.set(nil, forKey: "userImage")
        imageCache.removeObject(forKey: "userImage")
    }
    
    // Generic MALApi GET request
    private func getMALResponse<T: Codable>(urlExtend: String, type: T.Type) async throws -> T {
        let url = URL(string: malBaseApi + urlExtend)!
        await malBucket.consumeOrWaitAsync()
        let decoded: T = try await sendMALRequest(url: url, method: "GET")
        return decoded
    }
    
    // Generic JikanAPI GET request
    private func getJikanResponse<T: Codable>(urlExtend: String, type: T.Type) async throws -> T {
        let url = URL(string: jikanBaseApi + urlExtend)!
        await jikanBucket.consumeOrWaitAsync()
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
            
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badResponse
        }
            
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badStatusCode(httpResponse.statusCode)
        }
            
        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            throw NetworkError.jsonParseFailure
        }
    }
    
    func getUserAnimeList(page: Int, status: StatusEnum, sort: String) async throws -> [MALListAnime] {
        let response = try await getMALResponse(urlExtend: "/users/@me/animelist?fields=\(animeFields)&nsfw=true\(status == .none ? "" : "&status=\(status.toParameter())")&sort=\(sort)&limit=500&offset=\((page - 1) * 500)", type: MALAnimeListResponse.self)
        return response.data
    }
    
    func getUserMangaList(page: Int, status: StatusEnum, sort: String) async throws -> [MALListManga] {
        let response = try await getMALResponse(urlExtend: "/users/@me/mangalist?fields=\(mangaFields)&nsfw=true\(status == .none ? "" : "&status=\(status.toParameter())")&sort=\(sort)&limit=500&offset=\((page - 1) * 500)", type: MALMangaListResponse.self)
        return response.data
    }
    
    func getUserProfile(_ token: String? = nil) async throws {
        let url = URL(string: malBaseApi + "/users/@me")!
        let user: User = try await sendMALRequest(url: url, method: "GET", token: token)
        self.user = user
        UserDefaults.standard.set(user.name, forKey: "name")
        UserDefaults.standard.set(user.joinedAt, forKey: "joinedAt")
        UserDefaults.standard.set(user.picture, forKey: "picture")
    }
    
    func getUserStatistics() async throws -> UserStatistics {
        let response = try await getJikanResponse(urlExtend: "/users/\(user?.name ?? "")/statistics", type: JikanUserStatisticsResponse.self)
        return response.data
    }
    
    func getUserFavourites() async throws -> UserFavourites {
        let response = try await getJikanResponse(urlExtend: "/users/\(user?.name ?? "")/favorites", type: JikanUserFavouritesResponse.self)
        return response.data
    }
    
    func editUserAnime(id: Int, listStatus: MyListStatus, _ retries: Int = 3) async throws {
        let url = URL(string: malBaseApi + "/anime/\(id)/my_list_status")!
        let body = "status=\(listStatus.status!.toParameter())&score=\(listStatus.score)&num_watched_episodes=\(listStatus.numEpisodesWatched)&start_date=\(listStatus.startDate?.toMALString() ?? "")&finish_date=\(listStatus.finishDate?.toMALString() ?? "")".data(using: .utf8)!
        let _: MyListStatus = try await sendMALRequest(url: url, method: "PATCH", body: body, "application/x-www-form-urlencoded")
        print("edited anime successfully")
    }
    
    func editUserManga(id: Int, listStatus: MyListStatus, _ retries: Int = 3) async throws {
        let url = URL(string: malBaseApi + "/manga/\(id)/my_list_status")!
        let body = "status=\(listStatus.status!.toParameter())&score=\(listStatus.score)&num_volumes_read=\(listStatus.numVolumesRead)&num_chapters_read=\(listStatus.numChaptersRead)&start_date=\(listStatus.startDate?.toMALString() ?? "")&finish_date=\(listStatus.finishDate?.toMALString() ?? "")".data(using: .utf8)!
        let _: MyListStatus = try await sendMALRequest(url: url, method: "PATCH", body: body, "application/x-www-form-urlencoded")
        print("edited manga successfully")
    }
    
    func deleteUserAnime(id: Int) async throws {
        let url = URL(string: malBaseApi + "/anime/\(id)/my_list_status")!
        let _: MALEmptyResponse = try await sendMALRequest(url: url, method: "DELETE")
        print("deleted anime successfully")
    }
    
    func deleteUserManga(id: Int) async throws {
        let url = URL(string: malBaseApi + "/manga/\(id)/my_list_status")!
        let _: MALEmptyResponse = try await sendMALRequest(url: url, method: "DELETE")
        print("deleted manga successfully")
    }
    
    func getRandomAnime() async throws -> Int {
        let response = try await getJikanResponse(urlExtend: "/random/anime", type: JikanRandomItemResponse.self)
        return response.data.malId
    }
    
    func getRandomManga() async throws -> Int {
        let response = try await getJikanResponse(urlExtend: "/random/manga", type: JikanRandomItemResponse.self)
        return response.data.malId
    }
    
    func getRandomCharacter() async throws -> Int {
        let response = try await getJikanResponse(urlExtend: "/random/characters", type: JikanRandomItemResponse.self)
        return response.data.malId
    }
    
    func getRandomPerson() async throws -> Int {
        let response = try await getJikanResponse(urlExtend: "/random/people", type: JikanRandomItemResponse.self)
        return response.data.malId
    }
    
    func getNews() async throws -> [RSSFeedItem]? {
        let rssfeed = try await RSSFeed(urlString: "https://myanimelist.net/rss/news.xml")
        return rssfeed.channel?.items
    }
    
    func getUserAnimeSuggestionList() async throws -> [MALListAnime] {
        let response = try await getMALResponse(urlExtend: "/anime/suggestions?fields=\(animeFields)", type: MALAnimeListResponse.self)
        return response.data
    }
    
    func getAnimeTopAiringList() async throws -> [MALListAnime] {
        let response = try await getMALResponse(urlExtend: "/anime/ranking?ranking_type=airing&limit=10&fields=\(animeFields)", type: MALAnimeListResponse.self)
        return response.data
    }
    
    func getAnimeTopUpcomingList() async throws -> [MALListAnime] {
        let response = try await getMALResponse(urlExtend: "/anime/ranking?ranking_type=upcoming&limit=10&fields=\(animeFields)", type: MALAnimeListResponse.self)
        return response.data
    }
    
    func getAnimeNewlyAddedList() async throws -> [JikanListItem] {
        let response = try await getJikanResponse(urlExtend: "/anime?order_by=mal_id&sort=desc&limit=20&sfw=true", type: JikanListResponse.self)
        return response.data
    }
    
    func getMangaNewlyAddedList() async throws -> [JikanListItem] {
        let response = try await getJikanResponse(urlExtend: "/manga?order_by=mal_id&sort=desc&limit=20&sfw=true", type: JikanListResponse.self)
        return response.data
    }
    
    func getTopAnimeList(page: Int, rankingType: String) async throws -> [MALListAnime] {
        let response = try await getMALResponse(urlExtend: "/anime/ranking?ranking_type=\(rankingType)&limit=500&offset=\((page - 1) * 500)&fields=\(animeFields)&nsfw=true", type: MALAnimeListResponse.self)
        return response.data
    }
    
    func getTopMangaList(page: Int, rankingType: String) async throws -> [MALListManga] {
        let response = try await getMALResponse(urlExtend: "/manga/ranking?ranking_type=\(rankingType)&limit=500&offset=\((page - 1) * 500)&fields=\(mangaFields)&nsfw=true", type: MALMangaListResponse.self)
        return response.data
    }
    
    func getSeasonAnimeList(season: String, year: Int, page: Int) async throws -> [MALListAnime] {
        let response = try await getMALResponse(urlExtend: "/anime/season/\(year)/\(season)?nsfw=true&fields=\(animeFields)&sort=anime_num_list_users&limit=500&offset=\((page - 1) * 500)", type: MALAnimeListResponse.self)
        return response.data
    }
    
    func searchAnime(anime: String) async throws -> [MALListAnime] {
        let response = try await getMALResponse(urlExtend: "/anime?q=\(anime)&limit=100&nsfw=true&fields=\(animeFields)", type: MALAnimeListResponse.self)
        return response.data
    }
    
    func searchManga(manga: String) async throws -> [MALListManga] {
        let response = try await getMALResponse(urlExtend: "/manga?q=\(manga)&limit=100&nsfw=true&fields=\(mangaFields)", type: MALMangaListResponse.self)
        return response.data
    }
    
    func searchCharacter(character: String) async throws -> [JikanListItem] {
        let response = try await getJikanResponse(urlExtend: "/characters?q=\(character)&order_by=favorites&sort=desc", type: JikanListResponse.self)
        return response.data
    }
    
    func searchPerson(person: String) async throws -> [JikanListItem] {
        let response = try await getJikanResponse(urlExtend: "/people?q=\(person)&order_by=favorites&sort=desc", type: JikanListResponse.self)
        return response.data
    }
    
    func getAnimeList(urlExtend: String, page: Int) async throws -> [JikanListItem] {
        let response = try await getJikanResponse(urlExtend: "/anime?" + urlExtend + "&page=\(page)&order_by=members&sort=desc", type: JikanListResponse.self)
        return response.data
    }
    
    func getMangaList(urlExtend: String, page: Int) async throws -> [JikanListItem] {
        let response = try await getJikanResponse(urlExtend: "/manga?" + urlExtend + "&page=\(page)&order_by=members&sort=desc", type: JikanListResponse.self)
        return response.data
    }
    
    func getAnimeDetails(id: Int) async throws -> Anime {
        let response = try await getMALResponse(urlExtend: "/anime/\(id)?fields=\(animeFields)", type: Anime.self)
        return response
    }
    
    func getAnimeNextAiringDetails(id: Int) async throws -> NextAiringEpisode? {
        let url = URL(string: anilistBaseApi)!
        let query = """
            query Media {
                Media(idMal: \(id), type: ANIME) {
                    nextAiringEpisode {
                        airingAt
                        timeUntilAiring
                        episode
                    }
                }
            }
            """
        let body = ["query": query]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField:"Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: body)
        await anilistBucket.consumeOrWaitAsync()
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badStatusCode(httpResponse.statusCode)
        }
        
        do {
            let decoded = try decoder.decode(AniListAiringResponse.self, from: data)
            return decoded.data.Media.nextAiringEpisode
        } catch {
            throw NetworkError.jsonParseFailure
        }
    }
    
    func getAnimeCharacters(id: Int) async throws -> [ListCharacter] {
        let response = try await getJikanResponse(urlExtend: "/anime/\(id)/characters", type: JikanCharactersListResponse.self)
        return response.data
    }
    
    func getAnimeRelations(id: Int) async throws -> [Related] {
        let response = try await getJikanResponse(urlExtend: "/anime/\(id)/relations", type: JikanRelationsListResponse.self)
        return response.data
    }
    
    func getAnimeStaff(id: Int) async throws -> [Staff] {
        let response = try await getJikanResponse(urlExtend: "/anime/\(id)/staff", type: JikanStaffsListResponse.self)
        return response.data
    }
    
    func getAnimeReviewsList(id: Int, page: Int) async throws -> [Review] {
        let response = try await getJikanResponse(urlExtend: "/anime/\(id)/reviews?page=\(page)&preliminary=true", type: JikanReviewsListResponse.self)
        return response.data
    }
    
    func getMangaDetails(id: Int) async throws -> Manga {
        let response = try await getMALResponse(urlExtend: "/manga/\(id)?fields=\(mangaFields)", type: Manga.self)
        return response
    }
    
    func getMangaCharacters(id: Int) async throws -> [ListCharacter] {
        let response = try await getJikanResponse(urlExtend: "/manga/\(id)/characters", type: JikanCharactersListResponse.self)
        return response.data
    }
    
    func getMangaRelations(id: Int) async throws -> [Related] {
        let response = try await getJikanResponse(urlExtend: "/manga/\(id)/relations", type: JikanRelationsListResponse.self)
        return response.data
    }
    
    func getMangaReviewsList(id: Int, page: Int) async throws -> [Review] {
        let response = try await getJikanResponse(urlExtend: "/manga/\(id)/reviews?page=\(page)&preliminary=true", type: JikanReviewsListResponse.self)
        return response.data
    }
    
    func getCharacterDetails(id: Int) async throws -> Character {
        let response = try await getJikanResponse(urlExtend: "/characters/\(id)/full", type: JikanCharacterDetailsResponse.self)
        return response.data
    }
    
    func getPersonDetails(id: Int) async throws -> Person {
        let response = try await getJikanResponse(urlExtend: "/people/\(id)/full", type: JikanPersonDetailsResponse.self)
        return response.data
    }
    
    // Download image
    private func download(imageUrl: URL) async throws -> Data {
        let (localUrl, response) = try await URLSession.shared.download(for: URLRequest(url: imageUrl))
            
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badResponse
        }
            
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badStatusCode(httpResponse.statusCode)
        }
            
        do {
            let data = try Data(contentsOf: localUrl)
            return data
        } catch let error {
            throw NetworkError.unknownError(error)
        }
    }
    
    // Retrieve image from image cache
    func getImage(id: String) -> Data? {
        if let cache = imageCache.object(forKey: id as NSString) {
            return cache.image as Data
        }
        return nil
    }
    
    // Wrapper function for download
    func downloadImage(id: String, imageUrl: String?) async -> Data? {
        if let cache = imageCache.object(forKey: id as NSString) {
            return cache.image as Data
        }
        if let imageUrl = imageUrl {
            do {
                imageUrlMap[id] = imageUrl
                let url = URL(string: imageUrl)!
                let data = try await download(imageUrl: url)
                let cache = ImageCache()
                cache.image = data as NSData
                self.imageCache.setObject(cache, forKey: id as NSString)
                return data
            } catch {
                print("Error downloading image")
            }
        }
        return nil
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
