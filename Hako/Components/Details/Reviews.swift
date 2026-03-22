//
//  Reviews.swift
//  Hako
//
//  Created by Gao Tianrun on 14/6/25.
//

import SwiftUI

struct Reviews: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var reviewsPreview: [Review] = []
    private let id: Int
    private let type: TypeEnum
    private let reviews: [Review]?
    private let width: CGFloat
    private let loadingState: LoadingEnum
    private let load: () async -> Void
    
    init(id: Int, type: TypeEnum, reviews: [Review]?, width: CGFloat, loadingState: LoadingEnum, load: @escaping () async -> Void) {
        self.id = id
        self.type = type
        self.reviews = reviews
        self.width = width
        self.loadingState = loadingState
        self.load = load
    }
    
    var body: some View {
        ScrollViewCarousel(title: "Reviews", count: reviews?.count, viewAlignedScroll: true, loadingState: loadingState, refresh: load) { isLoading in
            PlaceholderReview(isLoading: isLoading)
                .frame(width: width, alignment: .center)
        } content: {
            ForEach(reviewsPreview) { item in
                ReviewItem(item: item)
                    .frame(width: width, alignment: .center)
            }
        } destination: {
            ReviewsListView(id: id, type: type)
        }
        .task {
            await load()
        }
        .onChange(of: reviews?.count) {
            reviewsPreview = Array(reviews?.prefix(10) ?? [])
        }
    }
}
