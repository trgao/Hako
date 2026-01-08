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
        if let person = networker.personCache[id] {
            self.person = person
        }
        Task {
            await refresh()
        }
    }
    
    init(id: Int, name: String?) {
        self.id = id
        self.person = Person(id: id, name: name)
        if let person = networker.personCache[id] {
            self.person = person
        }
        Task {
            await refresh()
        }
    }
    
    // Refresh the current person details page
    func refresh() async {
        isLoading = true
        do {
            let person = try await networker.getPersonDetails(id: id)
            self.person = person
            networker.personCache[id] = person
        } catch {
            if case NetworkError.notFound = error {} else {
                isLoadingError = true
            }
        }
        isLoading = false
    }
}
