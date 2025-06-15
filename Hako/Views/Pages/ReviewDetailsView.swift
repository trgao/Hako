//
//  ReviewDetailsView.swift
//  Hako
//
//  Created by Gao Tianrun on 15/6/25.
//

import SwiftUI

struct ReviewDetailsView: View {
    private var item: Review
    
    init(item: Review) {
        self.item = item
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    if let username = item.user?.username, let date = item.date {
                        HStack {
                            ImageFrame(id: "user\(username)", imageUrl: item.user?.images?.jpg?.imageUrl, imageSize: .reviewUser)
                            Text("\(username) ・ \(date.toString())")
                                .font(.system(size: 12))
                                .bold()
                                .padding(5)
                        }
                    }
                    if let tags = item.tags {
                        TagCloudView(tags: tags)
                    }
                    Text(item.review ?? "")
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.system(size: 17))
                }
                .padding(10)
            }
        }
    }
}
