//
//  RandomMangaView.swift
//  Hako
//
//  Created by Gao Tianrun on 26/6/25.
//

import Foundation
import SwiftUI
import Retry

struct RandomMangaView: View {
    @StateObject private var controller = RandomMangaViewController()
    
    var body: some View {
        if let id = controller.id {
            MangaDetailsView(id: id)
        } else {
            LoadingView()
        }
    }
}

@MainActor
class RandomMangaViewController: ObservableObject {
    @Published var id: Int?
    let networker = NetworkManager.shared
    
    init() {
        Task {
            try? await retry {
                self.id = try? await networker.getRandomManga()
            }
        }
    }
}
