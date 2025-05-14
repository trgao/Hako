//
//  AuthorsController.swift
//  MALC
//
//  Created by Gao Tianrun on 21/5/24.
//

import Foundation

@MainActor
class AuthorsController: ObservableObject {
    @Published var authors: [Author]
    @Published var isLoading = false
    let networker = NetworkManager.shared
    
    init(id: Int, authors: [Author]?) {
        self.authors = authors ?? []
        if let authors = networker.mangaAuthorsCache[id] {
            self.authors = authors
        } else {
            self.isLoading = true
            Task {
                do {
                    self.authors = try await self.authors.concurrentMap { author in
                        var newAuthor = author
                        let person = try await self.networker.getPersonDetails(id: author.id)
                        newAuthor.imageUrl = person.images.jpg.imageUrl
                        return newAuthor
                    }
                    networker.mangaAuthorsCache[id] = self.authors
                    self.isLoading = false
                } catch {
                    print("Some unknown error occurred loading authors")
                    print(error)
                    self.isLoading = false
                }
            }
        }
    }
}
