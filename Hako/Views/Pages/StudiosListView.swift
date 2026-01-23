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
            List {
                if controller.isLoading && controller.studios.isEmpty {
                    LoadingList(length: 20, showImage: false)
                } else if controller.isLoadingError && controller.studios.isEmpty {
                    ErrorView(refresh: controller.refresh)
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
                    if controller.isLoading {
                        LoadingList(length: 5, showImage: false)
                    }
                }
            }
            .disabled(controller.isLoading && controller.studios.isEmpty)
            .refreshable {
                isRefresh = true
            }
            .task(id: isRefresh) {
                if controller.studios.isEmpty || isRefresh {
                    await controller.refresh()
                    await controller.loadMore()
                    isRefresh = false
                }
            }
            if controller.isLoading && isRefresh {
                LoadingView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Studios")
    }
}
