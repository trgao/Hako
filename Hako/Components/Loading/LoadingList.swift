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
            NavigationLink {
                EmptyView()
            } label: {
                HStack {
                    if showImage {
                        ImageFrame(id: "", imageUrl: nil, imageSize: Constants.listImageSize)
                        VStack(alignment: .leading) {
                            Text("placeholderplaceholder")
                                .font(.callout)
                            Text("placeholder")
                                .font(.footnote)
                        }
                        .padding(5)
                    } else {
                        Text("placeholder placeholder")
                    }
                }
                .skeleton()
            }
            .padding(5)
            .disabled(true)
        }
        .id(id)
        .onDisappear {
            id = UUID()
        }
    }
}
