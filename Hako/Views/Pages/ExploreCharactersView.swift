//
//  ExploreCharactersView.swift
//  Hako
//
//  Created by Gao Tianrun on 7/1/26.
//

import SwiftUI

struct ExploreCharactersView: View {
    @StateObject private var controller = ExploreCharactersViewController()
    @State private var isRefresh = false
    
    var body: some View {
        ZStack {
            if controller.isLoadingError && controller.characters.isEmpty {
                ErrorView(refresh: controller.refresh)
            } else {
                List {
                    if controller.isLoading && controller.characters.isEmpty {
                        LoadingList(length: 20)
                    } else {
                        ForEach(Array(controller.characters.enumerated()), id: \.1.id) { index, character in
                            CharacterListItem(character: character)
                                .onAppear {
                                    Task {
                                        await controller.loadMoreIfNeeded(index: index)
                                    }
                                }
                        }
                        if controller.isLoading {
                            LoadingList(length: 5)
                        }
                    }
                }
                .disabled(controller.isLoading && controller.characters.isEmpty)
                .refreshable {
                    isRefresh = true
                }
                .task(id: isRefresh) {
                    if controller.characters.isEmpty || isRefresh {
                        await controller.refresh()
                        isRefresh = false
                    }
                }
                if controller.isLoading && isRefresh {
                    LoadingView()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Characters")
    }
}
