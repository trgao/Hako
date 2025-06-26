//
//  RandomPersonView.swift
//  Hako
//
//  Created by Gao Tianrun on 26/6/25.
//

import Foundation
import SwiftUI
import Retry

struct RandomPersonView: View {
    @StateObject private var controller = RandomPersonViewController()
    
    var body: some View {
        if let id = controller.id {
            PersonDetailsView(id: id)
        } else {
            LoadingView()
        }
    }
}

@MainActor
class RandomPersonViewController: ObservableObject {
    @Published var id: Int?
    let networker = NetworkManager.shared
    
    init() {
        Task {
            try? await retry {
                self.id = try? await networker.getRandomPerson()
            }
        }
    }
}
