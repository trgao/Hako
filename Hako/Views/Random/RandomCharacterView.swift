//
//  RandomCharacterView.swift
//  Hako
//
//  Created by Gao Tianrun on 26/6/25.
//

import SwiftUI

struct RandomCharacterView: View {
    @StateObject private var controller = RandomCharacterViewController()
    
    var body: some View {
        if let id = controller.id {
            CharacterDetailsView(id: id)
        } else if controller.isError {
            ErrorView(refresh: controller.refresh)
        } else {
            LoadingView()
        }
    }
}

@MainActor
class RandomCharacterViewController: ObservableObject {
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
            self.id = try await networker.getRandomCharacter()
        } catch {
            isError = true
        }
    }
}
