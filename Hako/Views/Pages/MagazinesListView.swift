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
            if controller.isLoadingError && controller.magazines.isEmpty {
                ErrorView(refresh: controller.refresh)
                    .padding(.vertical, 50)
            } else {
                List {
                    if controller.isLoading && controller.magazines.isEmpty {
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
                        if controller.isLoading {
                            LoadingList(length: 5, showImage: false)
                        }
                    }
                }
                .disabled(controller.isLoading && controller.magazines.isEmpty)
                .refreshable {
                    isRefresh = true
                }
                .task(id: isRefresh) {
                    if controller.magazines.isEmpty || isRefresh {
                        await controller.refresh()
                        await controller.loadMore()
                        isRefresh = false
                    }
                }
                if controller.isLoading && isRefresh {
                    LoadingView()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Magazines")
    }
}
