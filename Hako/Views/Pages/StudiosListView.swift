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
            if controller.loadingState == .error && controller.studios.isEmpty {
                ErrorView(refresh: controller.refresh)
                    .padding(.vertical, 50)
            } else {
                List {
                    if controller.loadingState == .loading && controller.studios.isEmpty {
                        LoadingList(length: 20, showImage: false)
                    } else {
                        ForEach(controller.studios) { studio in
                            if let title = studio.titles?[0].title {
                                NavigationLink(title) {
                                    GroupDetailsView(title: title, group: "producers", id: studio.id, type: .anime)
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
                        if controller.loadingState == .paginating {
                            LoadingList(length: 5, showImage: false)
                        }
                    }
                }
                .disabled(controller.loadingState == .loading && controller.studios.isEmpty)
                .refreshable {
                    isRefresh = true
                }
                .task(id: isRefresh) {
                    if controller.studios.isEmpty || isRefresh {
                        await controller.refresh()
                        await controller.loadMore() // To trigger load more on refresh, especially on bigger screens
                        isRefresh = false
                    }
                }
                if isRefresh {
                    LoadingView()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Studios")
    }
}
