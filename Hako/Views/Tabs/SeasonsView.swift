//
//  SeasonsView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI

struct SeasonsView: View {
    @StateObject private var controller = SeasonsViewController()
    @State private var isRefresh = false
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 150), alignment: .top),
    ]
    let networker = NetworkManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                if controller.season == "winter" {
                    ScrollView {
                        if controller.isLoadingError && controller.winterItems.isEmpty {
                            ErrorView(refresh: { await controller.refresh() })
                        } else {
                            LazyVGrid(columns: columns) {
                                ForEach(controller.winterItems) { item in
                                    AnimeGridItem(id: item.id, title: item.node.title, imageUrl: item.node.mainPicture?.medium)
                                        .task {
                                            await controller.loadMoreIfNeeded(currentItem: item)
                                        }
                                }
                            }
                            .padding(10)
                        }
                    }
                    .navigationTitle("Winter")
                } else if controller.season == "spring" {
                    ScrollView {
                        if controller.isLoadingError && controller.springItems.isEmpty {
                            ErrorView(refresh: { await controller.refresh() })
                        } else {
                            LazyVGrid(columns: columns) {
                                ForEach(controller.springItems) { item in
                                    AnimeGridItem(id: item.id, title: item.node.title, imageUrl: item.node.mainPicture?.medium)
                                        .task {
                                            await controller.loadMoreIfNeeded(currentItem: item)
                                        }
                                }
                            }
                            .padding(10)
                        }
                    }
                    .navigationTitle("Spring")
                } else if controller.season == "summer" {
                    ScrollView {
                        if controller.isLoadingError && controller.summerItems.isEmpty {
                            ErrorView(refresh: { await controller.refresh() })
                        } else {
                            LazyVGrid(columns: columns) {
                                ForEach(controller.summerItems) { item in
                                    AnimeGridItem(id: item.id, title: item.node.title, imageUrl: item.node.mainPicture?.medium)
                                        .task {
                                            await controller.loadMoreIfNeeded(currentItem: item)
                                        }
                                }
                            }
                            .padding(10)
                        }
                    }
                    .navigationTitle("Summer")
                } else if controller.season == "fall" {
                    ScrollView {
                        if controller.isLoadingError && controller.fallItems.isEmpty {
                            ErrorView(refresh: { await controller.refresh() })
                        } else {
                            LazyVGrid(columns: columns) {
                                ForEach(controller.fallItems) { item in
                                    AnimeGridItem(id: item.id, title: item.node.title, imageUrl: item.node.mainPicture?.medium)
                                        .task {
                                            await controller.loadMoreIfNeeded(currentItem: item)
                                        }
                                }
                            }
                            .padding(10)
                        }
                    }
                    .navigationTitle("Fall")
                }
                SeasonPicker(controller: controller)
                    .disabled(controller.getCurrentSeasonLoading())
                if controller.getCurrentSeasonLoading() {
                    LoadingView()
                }
                if controller.isSeasonEmpty() && !controller.getCurrentSeasonLoading() && !controller.isLoadingError {
                    VStack {
                        Image(systemName: "calendar")
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text("Nothing found. ")
                            .bold()
                    }
                }
            }
            .task(id: isRefresh) {
                if controller.shouldRefresh() || isRefresh {
                    await controller.refresh()
                    isRefresh = false
                }
            }
            .refreshable {
                isRefresh = true
            }
            .toolbar {
                YearPicker(controller: controller)
                    .disabled(controller.getCurrentSeasonLoading())
            }
        }
    }
}
