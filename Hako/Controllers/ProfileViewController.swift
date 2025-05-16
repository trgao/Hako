//
//  ProfileViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 22/11/24.
//

import Foundation

@MainActor
class ProfileViewController: ObservableObject {
    @Published var userStatistics: UserStatistics?
    let networker = NetworkManager.shared
    
    func refresh() async -> Void {
        let userStatistics = try? await networker.getUserStatistics()
        if let userStatistics = userStatistics {
            self.userStatistics = userStatistics
        }
    }
}
