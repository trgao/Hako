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
    @Published var isLoading = true
    let networker = NetworkManager.shared
    
    init(id: Int) {
        Task {
            let staffs = try? await networker.getAnimeStaff(id: id)
            self.staffs = staffs ?? []
            self.isLoading = false
        }
    }
}
