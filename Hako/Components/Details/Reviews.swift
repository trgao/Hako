//
//  Reviews.swift
//  Hako
//
//  Created by Gao Tianrun on 14/6/25.
//

import SwiftUI

struct Reviews: View {
    @Environment(\.colorScheme) private var colorScheme
    private let id: Int
    private let type: TypeEnum
    private let reviews: [Review]
    private let width: CGFloat
    private let load: () async -> Void
    
    init(id: Int, type: TypeEnum, reviews: [Review], width: CGFloat, load: @escaping () async -> Void) {
        self.id = id
        self.type = type
        self.reviews = reviews
        self.width = width
        self.load = load
    }
    
    var body: some View {
        VStack {
            if !reviews.isEmpty {
                ScrollViewCarousel(title: "Reviews", count: reviews.count, viewAlignedScroll: true) {
                    ForEach(reviews.prefix(10)) { item in
                        ReviewItem(item: item)
                            .frame(width: width, alignment: .center)
                    }
                } destination: {
                    ReviewsListView(id: id, type: type)
                }
            }
        }
        .task {
            await load()
        }
    }
}
