//
//  Router.swift
//  Hako
//
//  Created by Gao Tianrun on 23/10/26.
//

import SwiftUI

@Observable
@MainActor
final class Router {
    var path: [Route] = [] {
        didSet {
            if path.count > oldValue.count, case .userList = path.last {
                resetPickers()
            }
        }
    }

    var isRoot: Bool {
        path.isEmpty
    }

    var isUserListPresented: Bool {
        if case .userList = path.last {
            return true
        }
        return false
    }

    // User list view states
    var pickerType: TypeEnum = .anime
    var pickerAnimeStatus: StatusEnum = .watching
    var pickerMangaStatus: StatusEnum = .reading
    var pickerDisabled = false

    private func resetPickers() {
        pickerType = .anime
        pickerAnimeStatus = .watching
        pickerMangaStatus = .reading
        pickerDisabled = false
    }

    func push(_ item: Route) {
        path.append(item)
    }

    func pop() {
        guard !path.isEmpty else {
            return
        }
        path.removeLast()
    }

    func popToRoot() {
        // Resets the stack entirely
        path = []
    }

    func restartWith(_ item: Route) {
        popToRoot()
        push(item)
    }
}

enum Screen: String, Hashable {
    case schedule, randomAnime, randomManga, randomCharacter, randomPerson, anime, manga, characters, people, news, top, companies, magazines, profile, general, appearance, customise, customiseExplore, safariExtension, about
}

enum Route: Hashable {
    case topDetail(TopDetail)
    case animeZoom(ZoomTransitionItem<Anime>)
    case mangaZoom(ZoomTransitionItem<Manga>)
    case characterZoom(ZoomTransitionItem<ZoomTransitionContent>)
    case personZoom(ZoomTransitionItem<ZoomTransitionContent>)
    case airing(ZoomTransitionItem<AiringSchedule>)
    case animeItem(MALListAnime)
    case mangaItem(MALListManga)
    case anime(Anime)
    case manga(Manga)
    case character(Character)
    case person(Person)
    case characterList([ListCharacter]?)
    case staffList([Staff]?)
    case relatedList(RelatedList)
    case themeList([Theme])
    case episode(Episode)
    case review(Review)
    case episodeList(EpisodeList)
    case chapterList(ChapterList)
    case reviewList(ReviewList)
    case userList(UserList)
    case groupList(GroupList)
    case groupDetail(GroupDetail)
    case viewItem(ViewItem)
    case screen(Screen)
}
