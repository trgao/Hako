//
//  StaffsController.swift
//  MALC
//
//  Created by Gao Tianrun on 19/5/24.
//

import Foundation

@MainActor
class StaffsController: ObservableObject {
    @Published var staffs: [Staff] = []
    @Published var isLoading = false
    let networker = NetworkManager.shared
    
    init(id: Int) {
        if let staffs = networker.animeStaffsCache[id] {
            self.staffs = staffs
        } else {
            self.isLoading = true
            Task {
                do {
                    let staffs = try await networker.getAnimeStaff(id: id)
                    self.staffs = staffs
                    networker.animeStaffsCache[id] = staffs
                    self.isLoading = false
                } catch {
                    self.isLoading = false
                }
            }
        }
    }
}
