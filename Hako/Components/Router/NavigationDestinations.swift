//
//  NavigationDestinations.swift
//  Hako
//
//  Created by Gao Tianrun on 23/10/26.
//

import SwiftUI

struct NavigationDestinationsViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .topDetail(let item):
                    TopView(id: .constant(item.id), type: .constant(item.type), animeRanking: .constant(item.animeRanking), mangaRanking: .constant(item.mangaRanking))

                case .animeZoom(let item):
                    AnimeDetailsView(anime: item.content)
                        .navigationTransition(.zoom(sourceID: "anime", in: item.namespaceId))

                case .mangaZoom(let item):
                    MangaDetailsView(manga: item.content)
                        .navigationTransition(.zoom(sourceID: "manga", in: item.namespaceId))

                case .characterZoom(let item):
                    CharacterDetailsView(id: item.content.id, name: item.content.name, imageUrl: item.content.imageUrl)
                        .navigationTransition(.zoom(sourceID: "character", in: item.namespaceId))

                case .personZoom(let item):
                    PersonDetailsView(id: item.content.id, name: item.content.name, imageUrl: item.content.imageUrl)
                        .navigationTransition(.zoom(sourceID: "person", in: item.namespaceId))

                case .airing(let item):
                    if let id = item.content.media.idMal {
                        AnimeDetailsView(anime: Anime(id: id, title: item.content.media.title?.romaji ?? "", enTitle: item.content.media.title?.english, jaTitle: item.content.media.title?.native, imageUrl: item.content.media.coverImage?.large))
                            .navigationTransition(.zoom(sourceID: "airing", in: item.namespaceId))
                    }

                case .animeItem(let item):
                    AnimeDetailsView(anime: item.node)

                case .mangaItem(let item):
                    MangaDetailsView(manga: item.node)

                case .anime(let item):
                    AnimeDetailsView(anime: item)

                case .manga(let item):
                    MangaDetailsView(manga: item)

                case .character(let item):
                    CharacterDetailsView(id: item.id, name: item.name, imageUrl: item.images?.jpg?.imageUrl)

                case .person(let item):
                    PersonDetailsView(id: item.id, name: item.name, imageUrl: item.images?.jpg?.imageUrl)

                case .characterList(let item):
                    if let item {
                        CharactersListView(characters: item)
                    }

                case .staffList(let item):
                    if let item {
                        StaffsListView(staffs: item)
                    }

                case .relatedList(let item):
                    if item.type == .anime {
                        RelatedGridView(relatedAnime: item.items)
                    } else if item.type == .manga {
                        RelatedGridView(relatedManga: item.items)
                    }

                case .themeList(let item):
                    ThemesListView(themes: item)

                case .episode(let item):
                    EpisodeDetailsView(item: item)

                case .review(let item):
                    ReviewDetailsView(item: item)

                case .episodeList(let item):
                    EpisodesListView(id: item.id)

                case .chapterList(let item):
                    ChaptersListView(id: item.id)

                case .reviewList(let item):
                    ReviewsListView(id: item.id, type: item.type)

                case .userList(let item):
                    UserListView(user: item.username, id: item.id, type: item.type, animeStatus: item.animeStatus, animeSort: item.animeSort, mangaStatus: item.mangaStatus, mangaSort: item.mangaSort)
                        .id(item.id)

                case .groupList(let item):
                    GroupsListView(title: item.group.capitalized, items: item.items, group: item.group, type: item.type)

                case .groupDetail(let item):
                    GroupDetailsView(title: item.name, group: item.group, id: item.id, type: item.type)
                        .id("\(item.group)\(item.id)")

                case .viewItem(let item):
                    switch item.type {
                    case .anime:
                        AnimeDetailsView(id: item.id)
                    case .manga:
                        MangaDetailsView(id: item.id)
                    case .character:
                        CharacterDetailsView(id: item.id)
                    case .person:
                        PersonDetailsView(id: item.id)
                    }

                case .screen(let screen):
                    switch screen {
                    case .schedule:
                        ScheduleView()
                    case .randomAnime:
                        RandomAnimeView()
                    case .randomManga:
                        RandomMangaView()
                    case .randomCharacter:
                        RandomCharacterView()
                    case .randomPerson:
                        RandomPersonView()
                    case .anime:
                        ExploreAnimeView()
                    case .manga:
                        ExploreMangaView()
                    case .characters:
                        ExploreCharactersView()
                    case .people:
                        ExplorePeopleView()
                    case .news:
                        NewsListView()
                    case .top:
                        TopView()
                    case .companies:
                        CompaniesListView()
                    case .magazines:
                        MagazinesListView()
                    case .profile:
                        ProfileView()
                    case .general:
                        GeneralView()
                    case .appearance:
                        AppearanceView()
                    case .customise:
                        CustomiseView()
                    case .customiseExplore:
                        CustomiseExploreView()
                    case .safariExtension:
                        SafariExtensionView()
                    case .about:
                        AboutView()
                    }
                }
            }
    }
}

extension View {
    func navigationDestinations() -> some View {
        modifier(NavigationDestinationsViewModifier())
    }
}

// Navigation destination models

struct TopDetail: Hashable {
    let id: UUID?
    let type: TypeEnum?
    let animeRanking: RankingEnum?
    let mangaRanking: RankingEnum?
}

struct ZoomTransitionItem<Item: Hashable>: Hashable {
    let content: Item
    let namespaceId: Namespace.ID
}

struct ZoomTransitionContent: Hashable {
    let id: Int
    let name: String?
    let imageUrl: String?
    let type: SearchEnum
}

struct GroupDetail: Hashable {
    let id: Int
    let name: String
    let type: TypeEnum
    let group: String
}

struct GroupList: Hashable {
    let items: [MALItem]
    let name: String
    let type: TypeEnum
    let group: String
}

struct ViewItem: Hashable {
    let type: ViewTypeEnum
    var id: Int = 0
}
