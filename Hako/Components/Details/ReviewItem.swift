//
//  ReviewItem.swift
//  Hako
//
//  Created by Gao Tianrun on 14/6/25.
//

import SwiftUI

struct ReviewItem: View {
    @Environment(\.colorScheme) private var colorScheme
    private let item: Review
    
    init(item: Review) {
        self.item = item
    }
    
    var body: some View {
        NavigationLink {
            ReviewDetailsView(item: item)
        } label: {
            VStack(alignment: .leading) {
                if let username = item.user?.username, let date = item.date {
                    NavigationLink {
                        UserProfileView(user: username)
                    } label: {
                        HStack {
                            ImageFrame(id: "user\(username)", imageUrl: item.user?.images?.jpg?.imageUrl, imageSize: .reviewUser)
                            Text("\(username) ・ \(date.toString())")
                        }
                    }
                    .buttonStyle(.plain)
                    .font(.caption)
                    .bold()
                    .padding(.bottom, 5)
                }
                HStack {
                    if let recommended = item.tags?.filter({ $0 == "Recommended" || $0 == "Not Recommended" || $0 == "Mixed Feelings" })[0] {
                        TagItem(text: recommended)
                    }
                    Spacer()
                    if let score = item.score, score > 0 {
                        Text("\(score) ⭐").bold()
                    }
                }
                Text(item.review ?? "")
                    .multilineTextAlignment(.leading)
                    .lineLimit(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(20)
            .background(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
            .shadow(radius: 0.5)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}
