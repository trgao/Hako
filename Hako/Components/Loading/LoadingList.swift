//
//  LoadingList.swift
//  Hako
//
//  Created by Gao Tianrun on 14/5/25.
//

import SwiftUI

struct LoadingList: View {
    @Environment(\.screenRatio) private var screenRatio
    @State private var id = UUID()
    private let dummyList: [Int]
    private let showImage: Bool
    private var width: CGFloat {
        Constants.listImageSize == .medium ? 100 * screenRatio : 75 * screenRatio
    }
    private var height: CGFloat {
        Constants.listImageSize == .medium ? 142 * screenRatio : 106 * screenRatio
    }
    
    init(length: Int, showImage: Bool = true) {
        self.dummyList = Array(0..<length)
        self.showImage = showImage
    }
    
    var body: some View {
        ForEach(dummyList, id: \.self) { id in
            HStack {
                if showImage {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.gray)
                        .opacity(0.7)
                        .frame(width: width, height: height)
                    VStack(alignment: .leading) {
                        Text("placeholderplaceholder")
                        Text("placeholder")
                            .font(.footnote)
                    }
                    .padding(5)
                } else {
                    Text("placeholder placeholder")
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
