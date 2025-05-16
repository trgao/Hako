//
//  LoadingCarousel.swift
//  Hako
//
//  Created by Gao Tianrun on 14/5/25.
//

import SwiftUI
import Shimmer

struct LoadingCarousel: View {
    private let dummyList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    
    var body: some View {
        VStack {
            Text("placeholder")
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 35)
                .font(.system(size: 17))
                .redacted(reason: .placeholder)
                .shimmering()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top) {
                    ForEach(dummyList, id: \.self) { id in
                        AnimeGridItem(id: id, title: "placeholder", imageUrl: nil)
                            .redacted(reason: .placeholder)
                            .shimmering()
                    }
                }
                .padding(.horizontal, 20)
            }
            .disabled(true)
        }
    }
}
