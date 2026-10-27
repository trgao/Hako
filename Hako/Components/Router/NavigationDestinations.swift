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
            .navigationDestination(for: TopDetail.self) { item in
                TopView(id: .constant(item.id), type: .constant(item.type), animeRanking: .constant(item.animeRanking), mangaRanking: .constant(item.mangaRanking))
            }
            .navigationDestination(for: ZoomTransitionItem<Anime>.self) { item in
                AnimeDetailsView(anime: item.content)
                    .navigationTransition(.zoom(sourceID: "anime", in: item.namespaceId))
            }
            .navigationDestination(for: ZoomTransitionItem<Manga>.self) { item in
                MangaDetailsView(manga: item.content)
                    .navigationTransition(.zoom(sourceID: "manga", in: item.namespaceId))
            }
            .navigationDestination(for: ZoomTransitionItem<ZoomTransitionContent>.self) { item in
                if item.content.type == .character {
                    CharacterDetailsView(id: item.content.id, name: item.content.name, imageUrl: item.content.imageUrl)
                        .navigationTransition(.zoom(sourceID: "character", in: item.namespaceId))
                } else if item.content.type == .person {
                    PersonDetailsView(id: item.content.id, name: item.content.name, imageUrl: item.content.imageUrl)
                        .navigationTransition(.zoom(sourceID: "person", in: item.namespaceId))
                }
            }
            .navigationDestination(for: ZoomTransitionItem<AiringSchedule>.self) { item in
                if let id = item.content.media.idMal {
                    AnimeDetailsView(anime: Anime(id: id, title: item.content.media.title?.romaji ?? "", enTitle: item.content.media.title?.english, jaTitle: item.content.media.title?.native, imageUrl: item.content.media.coverImage?.large))
                        .navigationTransition(.zoom(sourceID: "airing", in: item.namespaceId))
                }
            }
            .navigationDestination(for: MALListAnime.self) { item in
                AnimeDetailsView(anime: item.node)
            }
            .navigationDestination(for: MALListManga.self) { item in
                MangaDetailsView(manga: item.node)
            }
            .navigationDestination(for: Anime.self) { item in
                AnimeDetailsView(anime: item)
            }
            .navigationDestination(for: Manga.self) { item in
                MangaDetailsView(manga: item)
            }
            .navigationDestination(for: Character.self) { item in
                CharacterDetailsView(id: item.id, name: item.name, imageUrl: item.images?.jpg?.imageUrl)
            }
            .navigationDestination(for: Person.self) { item in
                PersonDetailsView(id: item.id, name: item.name, imageUrl: item.images?.jpg?.imageUrl)
            }
            .navigationDestination(for: Episode.self) { item in
                EpisodeDetailsView(item: item)
            }
            .navigationDestination(for: Review.self) { item in
                ReviewDetailsView(item: item)
            }
            .navigationDestination(for: UserList.self) { item in
                UserListView(user: item.username, id: item.id, type: item.type, animeStatus: item.animeStatus, animeSort: item.animeSort, mangaStatus: item.mangaStatus, mangaSort: item.mangaSort)
                    .id(item.id)
            }
            .navigationDestination(for: [ListCharacter].self) { item in
                CharactersListView(characters: item)
            }
            .navigationDestination(for: [Staff].self) { item in
                StaffsListView(staffs: item)
            }
            .navigationDestination(for: RelatedList.self) { item in
                if item.type == .anime {
                    RelatedGridView(relatedAnime: item.items)
                } else if item.type == .manga {
                    RelatedGridView(relatedManga: item.items)
                }
            }
            .navigationDestination(for: EpisodeList.self) { item in
                EpisodesListView(id: item.id)
            }
            .navigationDestination(for: ChapterList.self) { item in
                ChaptersListView(id: item.id)
            }
            .navigationDestination(for: ReviewList.self) { item in
                ReviewsListView(id: item.id, type: item.type)
            }
            .navigationDestination(for: [Theme].self) { item in
                ThemesListView(themes: item)
            }
            .navigationDestination(for: [Magazine].self) { item in
                GroupsListView(title: "Serialization", items: item.map { $0.node }, group: "magazines", type: .manga)
            }
            .navigationDestination(for: GroupList.self) { item in
                GroupsListView(title: item.group.capitalized, items: item.items, group: item.group, type: item.type)
            }
            .navigationDestination(for: GroupDetail.self) { item in
                GroupDetailsView(title: item.name, group: item.group, id: item.id, type: item.type)
            }
            .navigationDestination(for: String.self) { item in
                if item == "schedule" {
                    ScheduleView()
                } else if item == "randomAnime" {
                    RandomAnimeView()
                } else if item == "randomManga" {
                    RandomMangaView()
                } else if item == "randomCharacter" {
                    RandomCharacterView()
                } else if item == "randomPerson" {
                    RandomPersonView()
                } else if item == "anime" {
                    ExploreAnimeView()
                } else if item == "manga" {
                    ExploreMangaView()
                } else if item == "characters" {
                    ExploreCharactersView()
                } else if item == "people" {
                    ExplorePeopleView()
                } else if item == "news" {
                    NewsListView()
                } else if item == "top" {
                    TopView()
                } else if item == "companies" {
                    CompaniesListView()
                } else if item == "magazines" {
                    MagazinesListView()
                } else if item == "profile" {
                    ProfileView()
                } else if item == "general" {
                    GeneralView()
                } else if item == "appearance" {
                    AppearanceView()
                } else if item == "customise" {
                    CustomiseView()
                } else if item == "customiseExplore" {
                    CustomiseExploreView()
                } else if item == "safariExtension" {
                    SafariExtensionView()
                } else if item == "about" {
                    AboutView()
                } else {
                    NotFoundView()
                }
            }
            .navigationDestination(for: ViewItem.self) { item in
                switch item.type {
                case .anime: AnimeDetailsView(id: item.id)
                case .manga: MangaDetailsView(id: item.id)
                case .character: CharacterDetailsView(id: item.id)
                case .person: PersonDetailsView(id: item.id)
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

struct TopDetail: Hashable {
    let id: UUID?
    let type: TypeEnum?
    let animeRanking: RankingEnum?
    let mangaRanking: RankingEnum?
}

struct ViewItem: Hashable {
    let type: ViewTypeEnum
    var id: Int = 0
}
