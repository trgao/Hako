//
//  LoadingList.swift
//  Hako
//
//  Created by Gao Tianrun on 14/5/25.
//

import SwiftUI

struct LoadingList: View {
    private let dummyList: [Int]
    
    init(length: Int) {
        self.dummyList = Array(0...length)
    }
    
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
            .skeleton()
            .padding(5)
        }
    }
}
