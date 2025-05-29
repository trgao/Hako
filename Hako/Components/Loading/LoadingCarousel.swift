//
//  LoadingCarousel.swift
//  Hako
//
//  Created by Gao Tianrun on 14/5/25.
//

import SwiftUI
import Shimmer

struct LoadingCarousel: View {
    private let title: String
    private let dummyList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    
    init(title: String) {
        self.title = title
    }
    
    var body: some View {
        VStack {
            Text(title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 35)
                .font(.system(size: 17))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top) {
                    ForEach(dummyList, id: \.self) { id in
                        AnimeGridItem(id: id, title: "placeholder", enTitle: "placeholder", imageUrl: nil)
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
