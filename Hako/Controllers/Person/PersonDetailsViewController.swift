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
    @Published var loadingState: LoadingEnum = .loading
    private let id: Int
    private let networker = NetworkManager.shared
    
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
        loadingState = .loading
        do {
            let person = try await networker.getPersonDetails(id: id)
            self.person = person
            networker.personCache[id] = person
            loadingState = .idle
        } catch {
            if case NetworkError.notFound = error {
                loadingState = .idle
            } else {
                loadingState = .error
            }
        }
    }
}
