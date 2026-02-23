//
//  MangaReviews.swift
//  Hako
//
//  Created by Gao Tianrun on 14/6/25.
//

import SwiftUI

struct MangaReviews: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var controller: MangaDetailsViewController
    private let id: Int
    private let width: CGFloat
    
    init(id: Int, controller: MangaDetailsViewController, width: CGFloat) {
        self.id = id
        self._controller = StateObject(wrappedValue: controller)
        self.width = width
    }
    
    var body: some View {
        VStack {
            if !controller.reviews.isEmpty {
                ScrollViewCarousel(title: "Reviews", count: controller.reviews.count, viewAlignedScroll: true) {
                    ForEach(controller.reviews.prefix(10)) { item in
                        ReviewItem(item: item)
                            .frame(width: width, alignment: .center)
                    }
                } destination: {
                    ReviewsListView(id: id, type: .manga)
                }
            }
        }
        .task {
            await controller.loadReviews()
        }
    }
}
