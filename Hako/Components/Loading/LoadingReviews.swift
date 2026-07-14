//
//  LoadingReviews.swift
//  Hako
//
//  Created by Gao Tianrun on 14/7/26.
//

import SwiftUI

struct LoadingReviews: View {
    @Environment(\.colorScheme) private var colorScheme
    private let sentiment: SentimentEnum
    
    init(sentiment: SentimentEnum) {
        self.sentiment = sentiment
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(0..<10, id: \.self) { _ in
                    PlaceholderReview(sentiment: sentiment)
                }
            }
            .padding(17)
        }
        .disabled(true)
        .background(colorScheme == .light ? Color(.systemGray6) : .black)
    }
}
