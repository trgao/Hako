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
                ScrollView {
                    if controller.isLoadingError && controller.isSeasonEmpty() {
                        ErrorView(refresh: { await controller.refresh() })
                    } else {
                        LazyVGrid(columns: columns) {
                            ForEach(controller.getCurrentSeasonItems()) { item in
                                AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large)
                                    .task {
                                        await controller.loadMoreIfNeeded(currentItem: item)
                                    }
                            }
                            if !controller.getCurrentSeasonCanLoadMore() && !controller.isSeasonContinuingEmpty() {
                                Section {
                                    ForEach(controller.getCurrentSeasonContinuingItems()) { item in
                                        AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large)
                                    }
                                } header: {
                                    Text("Continuing series")
                                        .padding(.top, 10)
                                        .padding(10)
                                        .bold()
                                        .font(.title2)
                                }
                            }
                        }
                        .padding(10)
                        .padding(.bottom, 35)
                    }
                }
                .navigationTitle(controller.season.capitalized)
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
                        Text("Nothing found")
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
