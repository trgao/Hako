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
                for i in self.authors.indices {
                    let person = try await networker.getPersonDetails(id: self.authors[i].id)
                    self.authors[i].imageUrl = person.images.jpg.imageUrl
                }
                isLoading = false
            } catch {
                isLoading = false
            }
        }
    }
}
