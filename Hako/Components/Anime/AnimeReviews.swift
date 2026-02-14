//
//  AnimeReviews.swift
//  Hako
//
//  Created by Gao Tianrun on 14/6/25.
//

import SwiftUI

struct AnimeReviews: View {
    @Environment(\.screenSize) private var screenSize
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var controller: AnimeDetailsViewController
    private var id: Int
    
    init(id: Int, controller: AnimeDetailsViewController) {
        self.id = id
        self._controller = StateObject(wrappedValue: controller)
    }
    
    var body: some View {
        VStack {
            if !controller.reviews.isEmpty {
                ScrollViewCarousel(title: "Reviews", items: controller.reviews) {
                    ScrollView(.horizontal) {
                        HStack(alignment: .top) {
                            ForEach(controller.reviews.prefix(10)) { item in
                                ReviewItem(item: item)
                                    .frame(width: screenSize.width - 34, alignment: .center)
                            }
                        }
                        .padding(.horizontal, 17)
                        .scrollTargetLayout()
                    }
                    .scrollIndicators(.never)
                    .scrollTargetBehavior(.viewAligned)
                } destination: {
                    ReviewsListView(id: id, type: .anime)
                }
            }
        }
        .task {
            await controller.loadReviews()
        }
    }
}
