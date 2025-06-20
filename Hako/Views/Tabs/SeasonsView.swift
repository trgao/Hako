//
//  SeasonsView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI

struct SeasonsView: View {
    @EnvironmentObject private var settings: SettingsManager
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
                            ForEach(Array(controller.getCurrentSeasonItems().enumerated()), id: \.1.id) { index, item in
                                AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large)
                                    .task {
                                        await controller.loadMoreIfNeeded(index: index)
                                    }
                            }
                            if controller.getCurrentSeasonItems().count % 2 != 0 {
                                AnimeGridItem(id: 0, title: nil, enTitle: nil, imageUrl: nil)
                                    .hidden()
                            }
                            if !controller.getCurrentSeasonCanLoadMore() && !controller.isSeasonContinuingEmpty() && !settings.hideContinuingSeries {
                                Text("Continuing")
                                    .padding(.bottom, 10)
                                    .padding([.top, .horizontal], 20)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .bold()
                                    .font(.title2)
                                Rectangle()
                                    .frame(height: 20)
                                    .hidden()
                                ForEach(controller.getCurrentSeasonContinuingItems()) { item in
                                    AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large)
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, 45)
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
