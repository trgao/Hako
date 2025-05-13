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
    @Published var isLoading = true
    let networker = NetworkManager.shared
    
    init(authors: [Author]) {
        self.authors = authors
        Task {
            do {
                self.authors = try await authors.concurrentMap { author in
                    var newAuthor = author
                    let person = try await self.networker.getPersonDetails(id: author.id)
                    newAuthor.imageUrl = person.images.jpg.imageUrl
                    return newAuthor
                }
                self.isLoading = false
            } catch {
                print("Some unknown error occurred")
                self.isLoading = false
            }
        }
    }
}
