//
//  RandomMangaView.swift
//  Hako
//
//  Created by Gao Tianrun on 26/6/25.
//

import SwiftUI

struct RandomMangaView: View {
    @StateObject private var controller = RandomMangaViewController()
    
    var body: some View {
        if let id = controller.id {
            MangaDetailsView(id: id)
        } else if controller.isError {
            ErrorView(refresh: controller.refresh)
        } else {
            LoadingView()
        }
    }
}

@MainActor
class RandomMangaViewController: ObservableObject {
    @Published var id: Int?
    @Published var isError = false
    let networker = NetworkManager.shared
    
    init() {
        Task {
            await refresh()
        }
    }
    
    func refresh() async {
        do {
            self.id = try await networker.getRandomManga()
        } catch {
            isError = true
        }
    }
}
