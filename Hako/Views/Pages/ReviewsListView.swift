//
//  ReviewsListView.swift
//  Hako
//
//  Created by Gao Tianrun on 14/6/24.
//

import SwiftUI

struct ReviewsListView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var controller: ReviewsListViewController
    @State private var isRefresh = false
    
    init(id: Int, type: TypeEnum) {
        self._controller = StateObject(wrappedValue: ReviewsListViewController(id: id, type: type))
    }
    
    var body: some View {
        ZStack {
            if controller.isLoadingError && controller.reviews.isEmpty {
                ErrorView(refresh: controller.refresh)
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(Array(controller.reviews.enumerated()), id: \.1.id) { index, item in
                            ReviewItem(item: item)
                                .id(item.id)
                                .onAppear {
                                    Task {
                                        await controller.loadMoreIfNeeded(index: index)
                                    }
                                }
                        }
                        if controller.isLoading {
                            LoadingReviews()
                        }
                    }
                    .padding(17)
                }
                .background(colorScheme == .light ? Color(.systemGray6) : Color(.systemBackground))
                if isRefresh && controller.isLoading {
                    LoadingView()
                }
            }
        }
        .task(id: isRefresh) {
            if controller.reviews.isEmpty || isRefresh {
                await controller.refresh()
                isRefresh = false
            }
        }
        .refreshable {
            isRefresh = true
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Reviews")
    }
}
