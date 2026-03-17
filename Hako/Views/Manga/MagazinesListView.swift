//
//  MagazinesListView.swift
//  Hako
//
//  Created by Gao Tianrun on 9/1/26.
//

import SwiftUI

struct MagazinesListView: View {
    @StateObject private var controller = MagazinesListViewController()
    @State private var isRefresh = false
    
    var body: some View {
        ZStack {
            if controller.loadingState == .error && controller.magazines.isEmpty {
                ErrorView(refresh: controller.refresh)
                    .padding(.vertical, 50)
            } else {
                List {
                    if controller.loadingState == .loading && controller.magazines.isEmpty {
                        LoadingList(length: 20, showImage: false)
                    } else {
                        ForEach(controller.magazines) { magazine in
                            if let name = magazine.name {
                                NavigationLink(name) {
                                    GroupDetailsView(title: name, group: "magazines", id: magazine.id, type: .manga)
                                }
                                .onAppear {
                                    Task {
                                        if magazine.id == controller.magazines.last?.id {
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
                .disabled(controller.loadingState == .loading && controller.magazines.isEmpty)
                .refreshable {
                    isRefresh = true
                }
                .task(id: isRefresh) {
                    if controller.magazines.isEmpty || isRefresh {
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
        .navigationTitle("Magazines")
    }
}
