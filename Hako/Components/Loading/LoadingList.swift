//
//  LoadingList.swift
//  Hako
//
//  Created by Gao Tianrun on 14/5/25.
//

import SwiftUI

struct LoadingList: View {
    @State private var id = UUID()
    private let dummyList: [Int]
    private let showImage: Bool
    
    init(length: Int, showImage: Bool = true) {
        self.dummyList = Array(0..<length)
        self.showImage = showImage
    }
    
    var body: some View {
        ForEach(dummyList, id: \.self) { id in
            HStack {
                if showImage {
                    ImageFrame(id: "", imageUrl: nil, imageSize: .small)
                    VStack(alignment: .leading) {
                        Text("placeholder")
                            .bold()
                            .font(.system(size: 16))
                    }
                    .padding(5)
                } else {
                    Text("placeholder")
                }
            }
            .skeleton()
            .padding(5)
        }
        .id(id)
        .onDisappear {
            id = UUID()
        }
    }
}
