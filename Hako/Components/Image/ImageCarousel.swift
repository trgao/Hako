//
//  ImageCarousel.swift
//  Hako
//
//  Created by Gao Tianrun on 12/7/25.
//

import SwiftUI

struct ImageCarousel: View {
    @Environment(\.dismiss) private var dismiss
    let pictures: [Picture]
    
    init(pictures: [Picture]?) {
        self.pictures = pictures ?? []
    }
    
    var body: some View {
        VStack(alignment: .trailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
            }
            .padding([.horizontal, .top], 20)
            TabView {
                ForEach(pictures.filter { $0.medium != nil }, id: \.medium) { item in
                    let url = item.large == nil ? item.medium : item.large
                    if let url = url {
                        AsyncImage(url: URL(string: url)!) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Color.gray
                        }
                        .frame(width: UIScreen.main.bounds.width * 9 / 10, height: (UIScreen.main.bounds.width * 9 / 10) / 150 * 212)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }
}

