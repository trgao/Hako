//
//  AnimeRelatedItems.swift
//  MALC
//
//  Created by Gao Tianrun on 6/5/24.
//

import SwiftUI

struct AnimeRelatedItems: View {
    @StateObject private var controller: AnimeDetailsViewController
    
    init(controller: AnimeDetailsViewController) {
        self._controller = StateObject(wrappedValue: controller)
    }
    
    var body: some View {
        if !controller.isLoading && !controller.relatedItems.isEmpty {
            Section {} header: {
                VStack {
                    Text("Related")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 30)
                        .font(.system(size: 17))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            Rectangle()
                                .frame(width: 5)
                                .foregroundColor(.clear)
                            ForEach(controller.relatedItems) { item in
                                if item.type == .anime {
                                    AnimeGridItem(id: item.id, title: item.name, imageUrl: item.imageUrl, subtitle: item.relation)
                                } else if item.type == .manga {
                                    MangaGridItem(id: item.id, title: item.name, imageUrl: item.imageUrl, subtitle: item.relation)
                                }
                            }
                            Rectangle()
                                .frame(width: 5)
                                .foregroundColor(.clear)
                        }
                    }
                }
                .textCase(nil)
                .padding(.horizontal, -15)
                .foregroundColor(Color.primary)
                .listRowInsets(.init())
            }
            .listRowInsets(.init())
        }
    }
}
