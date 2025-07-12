//
//  PersonDetailsViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 21/5/24.
//

import Foundation

@MainActor
class PersonDetailsViewController: ObservableObject {
    @Published var person: Person?
    @Published var isLoading = true
    @Published var isLoadingError = false
    private let id: Int
    let networker = NetworkManager.shared
    
    init(id: Int) {
        self.id = id
        Task {
            await refresh()
        }
    }
    
    // Refresh the current person details page
    func refresh() async -> Void {
        isLoading = true
        do {
            let person = try await networker.getPersonDetails(id: id)
            self.person = person
        } catch {
            isLoadingError = true
        }
        isLoading = false
    }
}
