//
//  RelatedItemsController.swift
//  MALC
//
//  Created by Gao Tianrun on 21/5/24.
//

import Foundation

@MainActor
class RelatedItemsController: ObservableObject {
    @Published var items: [RelatedItem]
    @Published var isLoading = true
    let networker = NetworkManager.shared
    
    init(items: [RelatedItem]) {
        self.items = items
        Task {
            do {
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
                self.isLoading = false
            } catch {
                print("Some unknown error occurred")
                self.isLoading = false
            }
        }
    }
}
