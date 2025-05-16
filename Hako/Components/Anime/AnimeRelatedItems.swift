//
//  AnimeRelatedItems.swift
//  Hako
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
        if !controller.relatedItems.isEmpty {
            Section {} header: {
                VStack {
                    Text("Related")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 35)
                        .font(.system(size: 17))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            ForEach(controller.relatedItems) { item in
                                if item.type == .anime {
                                    AnimeGridItem(id: item.id, title: item.name, imageUrl: item.imageUrl, subtitle: item.relation)
                                } else if item.type == .manga {
                                    MangaGridItem(id: item.id, title: item.name, imageUrl: item.imageUrl, subtitle: item.relation)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .textCase(nil)
                .padding(.horizontal, -20)
                .foregroundColor(Color.primary)
                .listRowInsets(.init())
            }
            .listRowInsets(.init())
        }
    }
}
