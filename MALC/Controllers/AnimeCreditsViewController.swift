//
//  AnimeCreditsViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 19/5/24.
//

import Foundation

@MainActor
class AnimeCreditsViewController: ObservableObject {
    @Published var staff = [Staff]()
    @Published var isLoading = false
    @Published var isLoadingError = false
    private let id: Int
    let networker = NetworkManager.shared
    
    init(id: Int) {
        self.id = id
    }
    
    // Refresh the current anime credits page
    func refresh() async -> Void {
        isLoading = true
        do {
            let staffList = try await networker.getAnimeStaff(id: id)
            self.staff = staffList
            
            isLoading = false
        } catch {
            isLoading = false
            isLoadingError = true
        }
    }
}
