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
    @State private var isInit = false
    @State private var isRefresh = false

    init(id: Int, type: TypeEnum) {
        self._controller = StateObject(wrappedValue: ReviewsListViewController(id: id, type: type))
    }

    private var nothingFoundView: some View {
        ContentUnavailableView(
            "No reviews",
            systemImage: "text.bubble"
        )
    }

    var body: some View {
        ZStack {
            if controller.reviews.isEmpty {
                if controller.loadingState == .loading {
                    LoadingReviews(sentiment: controller.sentiment)
                } else if controller.loadingState == .error {
                    ErrorView(refresh: { await controller.refresh() })
                } else if controller.loadingState == .idle {
                    nothingFoundView
                }
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
                    }
                    .padding(17)
                    if controller.loadingState == .paginating {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                    }
                }
                .background(colorScheme == .light ? Color(.systemGray6) : .black)
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
                isInit = true
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Reviews")
        .toolbar {
            Menu {
                Picker("Sentiment", selection: $controller.sentiment) {
                    ForEach(Constants.sentiments, id: \.self) { sentiment in
                        Label(sentiment.toString(), systemImage: sentiment.toIcon()).tag(sentiment)
                    }
                }
                .pickerStyle(.inline)
                .labelsVisibility(.visible)
            } label: {
                Label("Menu", systemImage: "line.3.horizontal.decrease.circle")
                    .labelStyle(.iconOnly)
            }
            .onChange(of: controller.sentiment) {
                if isInit {
                    Task {
                        await controller.refresh(true)
                    }
                }
            }
        }
    }
}
