//
//  RandomAnimeView.swift
//  Hako
//
//  Created by Gao Tianrun on 26/6/25.
//

import Foundation
import SwiftUI
import Retry

struct RandomAnimeView: View {
    @StateObject private var controller = RandomAnimeViewController()
    
    var body: some View {
        if let id = controller.id {
            AnimeDetailsView(id: id)
        } else {
            LoadingView()
        }
    }
}

@MainActor
class RandomAnimeViewController: ObservableObject {
    @Published var id: Int?
    let networker = NetworkManager.shared
    
    init() {
        Task {
            try? await retry {
                self.id = try? await networker.getRandomAnime()
            }
        }
    }
}
