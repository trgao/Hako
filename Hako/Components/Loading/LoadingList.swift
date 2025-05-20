//
//  LoadingList.swift
//  Hako
//
//  Created by Gao Tianrun on 14/5/25.
//

import SwiftUI
import Shimmer

struct LoadingList: View {
    private let dummyList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    
    var body: some View {
        ForEach(dummyList, id: \.self) { id in
            HStack {
                ImageFrame(id: "", imageUrl: nil, imageSize: .small)
                VStack(alignment: .leading) {
                    Text("placeholder")
                        .bold()
                        .font(.system(size: 16))
                }
                .padding(5)
            }
            .redacted(reason: .placeholder)
            .shimmering()
            .padding(5)
        }
    }
}
