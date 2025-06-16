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
    private var id: Int
    
    init(id: Int, controller: MangaDetailsViewController) {
        self.id = id
        self._controller = StateObject(wrappedValue: controller)
    }
    
    var body: some View {
        if !controller.reviews.isEmpty {
            Section {} header: {
                VStack {
                    ListViewLink(title: "Reviews", items: controller.reviews) {
                        ReviewsListView(id: id, type: .manga)
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            ForEach(controller.reviews.prefix(10)) { item in
                                ReviewItem(item: item)
                                    .frame(width: UIScreen.main.bounds.size.width - 30, alignment: .center)
                            }
                        }
                        .padding(.horizontal, 20)
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                }
                .textCase(nil)
                .padding(.horizontal, -20)
                .padding(.top, 5)
                .foregroundColor(Color.primary)
                .listRowInsets(.init())
            }
            .frame(maxWidth: .infinity)
            .listRowInsets(.init())
        }
    }
}
