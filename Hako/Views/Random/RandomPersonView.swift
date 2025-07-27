//
//  RandomPersonView.swift
//  Hako
//
//  Created by Gao Tianrun on 26/6/25.
//

import Foundation
import SwiftUI

struct RandomPersonView: View {
    @StateObject private var controller = RandomPersonViewController()
    
    var body: some View {
        if let id = controller.id {
            PersonDetailsView(id: id)
        } else if controller.isError {
            ErrorView(refresh: controller.refresh)
        } else {
            LoadingView()
        }
    }
}

@MainActor
class RandomPersonViewController: ObservableObject {
    @Published var id: Int?
    @Published var isError = false
    let networker = NetworkManager.shared
    
    init() {
        Task {
            await refresh()
        }
    }
    
    func refresh() async -> Void {
        do {
            self.id = try await networker.getRandomPerson()
        } catch {
            isError = true
        }
    }
}
