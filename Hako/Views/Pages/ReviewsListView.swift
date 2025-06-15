//
//  ReviewsListView.swift
//  Hako
//
//  Created by Gao Tianrun on 14/6/24.
//

import SwiftUI

struct ReviewsListView: View {
    @StateObject private var controller: ReviewsListViewController
    @State private var isRefresh = false
    
    init(id: Int, type: TypeEnum) {
        self._controller = StateObject(wrappedValue: ReviewsListViewController(id: id, type: type))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
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
                if isRefresh && controller.isLoading {
                    LoadingView()
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
            .navigationTitle("Reviews")
        }
    }
}
