//
//  RelatedItemsController.swift
//  MALC
//
//  Created by Gao Tianrun on 21/5/24.
//

import Foundation

@MainActor
class RelatedItemsController: ObservableObject {
    @Published var items: [RelatedItem] = []
    @Published var isLoading = false
    let networker = NetworkManager.shared
    
    init(id: Int, type: TypeEnum) {
        if type == .anime, let items = networker.animeRelatedCache[id] {
            self.items = items
        } else if type == .manga, let items = networker.mangaRelatedCache[id] {
            self.items = items
        } else {
            self.isLoading = true
            Task {
                do {
                    var relations: [Related] = []
                    if type == .anime {
                        relations = try await networker.getAnimeRelations(id: id)
                    } else if type == .manga {
                        relations = try await networker.getMangaRelations(id: id)
                    }
                    self.items = relations.flatMap{ category in category.entry.map{ RelatedItem(malId: $0.malId, type: $0.type, name: $0.name, url: $0.url, relation: category.relation, imageUrl: nil) } }
                    self.items = try await items.concurrentMap { item in
                        var newItem = item
                        if item.type == .anime {
                            let anime = try await NetworkManager.shared.getAnimeDetails(id: item.id)
                            newItem.imageUrl = anime.mainPicture?.medium
                        } else if item.type == .manga {
                            let manga = try await NetworkManager.shared.getMangaDetails(id: item.id)
                            newItem.imageUrl = manga.mainPicture?.medium
                        }
                        return newItem
                    }
                    if type == .anime {
                        networker.animeRelatedCache[id] = items
                    } else if type == .manga {
                        networker.mangaRelatedCache[id] = items
                    }
                    self.isLoading = false
                } catch {
                    print("Some unknown error occurred loading related")
                    self.isLoading = false
                }
            }
        }
    }
}
