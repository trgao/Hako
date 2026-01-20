//
//  LoadingCarousel.swift
//  Hako
//
//  Created by Gao Tianrun on 14/5/25.
//

import SwiftUI

struct LoadingCarousel: View {
    private let dummyList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top) {
                ForEach(dummyList, id: \.self) { id in
                    AnimeGridItem(id: id, title: "placeholder", enTitle: "placeholder", imageUrl: nil)
                        .skeleton()
                }
            }
            .padding(.horizontal, 17)
        }
        .scrollIndicators(.never)
        .disabled(true)
    }
}
