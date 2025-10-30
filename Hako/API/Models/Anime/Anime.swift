//
//  Anime.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import Foundation

struct Anime: Codable, Identifiable {
    let id: Int
    let title: String
    let mainPicture: MainPicture?
    let pictures: [Picture]?
    let alternativeTitles: AlternativeTitles?
    let startDate: Date?
    let endDate: Date?
    let synopsis: String?
    let mean: Double?
    let rank: Int?
    let popularity: Int?
    let mediaType: String?
    let status: String?
    let genres: [MALItem]?
    var myListStatus: MyListStatus?
    let numEpisodes: Int?
    let startSeason: Season?
    let broadcast: Broadcast?
    let source: String?
    let averageEpisodeDuration: Int?
    let rating: String?
    let studios: [MALItem]?
    let openingThemes: [Theme]?
    let endingThemes: [Theme]?
    let videos: [Video]?
    let recommendations: [MALListAnime]?
    let numListUsers: Int?
    
    init(id: Int, title: String, enTitle: String?) {
        self.id = id
        self.title = title
        self.alternativeTitles = AlternativeTitles(ja: nil, en: enTitle)
        self.mainPicture = nil
        self.pictures = nil
        self.startDate = nil
        self.endDate = nil
        self.synopsis = nil
        self.mean = nil
        self.rank = nil
        self.popularity = nil
        self.mediaType = nil
        self.status = nil
        self.genres = nil
        self.myListStatus = nil
        self.numEpisodes = nil
        self.startSeason = nil
        self.broadcast = nil
        self.source = nil
        self.averageEpisodeDuration = nil
        self.rating = nil
        self.studios = nil
        self.openingThemes = nil
        self.endingThemes = nil
        self.videos = nil
        self.recommendations = nil
        self.numListUsers = nil
    }
    
    init(item: JikanListItem) {
        self.id = item.id
        self.title = item.title ?? ""
        self.alternativeTitles = AlternativeTitles(ja: item.titleJapanese, en: item.titleEnglish)
        self.mainPicture = MainPicture(medium: item.images?.jpg?.imageUrl, large: item.images?.jpg?.largeImageUrl)
        self.pictures = nil
        self.startDate = nil
        self.endDate = nil
        self.synopsis = item.synopsis
        self.mean = item.score
        self.rank = item.rank
        self.popularity = item.popularity
        self.mediaType = item.type
        self.status = item.status
        self.genres = nil
        self.myListStatus = nil
        self.numEpisodes = item.episodes
        self.startSeason = Season(year: item.year, season: item.season)
        self.broadcast = nil
        self.source = item.source
        self.averageEpisodeDuration = nil
        self.rating = nil
        self.studios = nil
        self.openingThemes = nil
        self.endingThemes = nil
        self.videos = nil
        self.recommendations = nil
        self.numListUsers = item.members
    }
}
