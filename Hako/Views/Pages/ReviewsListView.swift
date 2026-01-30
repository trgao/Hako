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
            if controller.loadingState == .error && controller.reviews.isEmpty {
                ErrorView(refresh: controller.refresh)
            } else {
                ScrollView {
                    LazyVStack {
                        if controller.loadingState == .loading && controller.reviews.isEmpty {
                            LoadingReviews(length: 10)
                        } else {
                            ForEach(Array(controller.reviews.enumerated()), id: \.1.id) { index, item in
                                ReviewItem(item: item)
                                    .id(item.id)
                                    .onAppear {
                                        Task {
                                            await controller.loadMoreIfNeeded(index: index)
                                        }
                                    }
                            }
                            if controller.loadingState == .paginating {
                                LoadingReviews(length: 3)
                            }
                        }
                    }
                    .padding(17)
                }
                .disabled(controller.loadingState == .loading && controller.reviews.isEmpty)
                .background(colorScheme == .light ? Color(.systemGray6) : Color(.systemBackground))
                if isRefresh {
                    LoadingView()
                }
            }
        }
        .refreshable {
            isRefresh = true
        }
        .task(id: isRefresh) {
            if controller.reviews.isEmpty || isRefresh {
                await controller.refresh()
                isRefresh = false
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Reviews")
    }
}
