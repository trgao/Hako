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
            if controller.isLoading && controller.characters.isEmpty {
                List {
                    LoadingList(length: 20)
                }
                .disabled(true)
            } else {
                if controller.isLoadingError {
                    ErrorView(refresh: controller.refresh)
                } else {
                    List {
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
                    .refreshable {
                        isRefresh = true
                    }
                }
                if controller.isLoading && isRefresh {
                    LoadingView()
                }
            }
        }
        .task(id: isRefresh) {
            if controller.characters.isEmpty || isRefresh {
                await controller.refresh()
                isRefresh = false
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Characters")
    }
}
