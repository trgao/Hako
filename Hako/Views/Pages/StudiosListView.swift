//
//  StudiosListView.swift
//  Hako
//
//  Created by Gao Tianrun on 9/1/26.
//

import SwiftUI

struct StudiosListView: View {
    @StateObject private var controller = StudiosListViewController()
    @State private var isRefresh = false
    
    var body: some View {
        ZStack {
            if controller.isLoading && controller.studios.isEmpty {
                List {
                    LoadingList(length: 20, showImage: false)
                }
                .disabled(true)
            } else {
                if controller.isLoadingError && controller.studios.isEmpty {
                    ErrorView(refresh: controller.refresh)
                } else {
                    List {
                        ForEach(Array(controller.studios.enumerated()), id: \.1.id) { index, studio in
                            if let title = studio.titles?[0].title {
                                NavigationLink {
                                    GroupDetailsView(title: title, group: "producers", id: studio.id, type: .anime)
                                } label: {
                                    Text(title)
                                }
                                .onAppear {
                                    Task {
                                        if studio.id == controller.studios.last?.id {
                                            await controller.loadMore()
                                        }
                                    }
                                }
                            }
                        }
                        if controller.isLoading {
                            LoadingList(length: 5, showImage: false)
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
            if controller.studios.isEmpty || isRefresh {
                await controller.refresh()
                await controller.loadMore()
                isRefresh = false
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Studios")
    }
}
