//
//  RandomCharacterView.swift
//  Hako
//
//  Created by Gao Tianrun on 26/6/25.
//

import Foundation
import SwiftUI
import Retry

struct RandomCharacterView: View {
    @StateObject private var controller = RandomCharacterViewController()
    
    var body: some View {
        if let id = controller.id {
            CharacterDetailsView(id: id)
        } else {
            LoadingView()
        }
    }
}

@MainActor
class RandomCharacterViewController: ObservableObject {
    @Published var id: Int?
    let networker = NetworkManager.shared
    
    init() {
        Task {
            try? await retry {
                self.id = try? await networker.getRandomCharacter()
            }
        }
    }
}
