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
            if controller.isLoading && controller.magazines.isEmpty {
                List {
                    LoadingList(length: 20, showImage: false)
                }
                .disabled(true)
            } else {
                if controller.isLoadingError {
                    ErrorView(refresh: controller.refresh)
                } else {
                    List {
                        ForEach(Array(controller.magazines.enumerated()), id: \.1.id) { index, magazine in
                            if let name = magazine.name {
                                NavigationLink {
                                    GroupDetailsView(title: name, group: "magazines", id: magazine.id, type: .manga)
                                } label: {
                                    Text(name)
                                }
                                .onAppear {
                                    Task {
                                        await controller.loadMoreIfNeeded(index: index)
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
            if controller.magazines.isEmpty || isRefresh {
                await controller.refresh()
                isRefresh = false
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Magazines")
    }
}
