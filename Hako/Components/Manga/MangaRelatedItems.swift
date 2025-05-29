//
//  MangaRelatedItems.swift
//  Hako
//
//  Created by Gao Tianrun on 6/5/24.
//

import SwiftUI

struct MangaRelatedItems: View {
    @StateObject private var controller: MangaDetailsViewController
    
    init(controller: MangaDetailsViewController) {
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
                                    AnimeGridItem(id: item.id, title: item.title, enTitle: item.enTitle, imageUrl: item.imageUrl, subtitle: item.relation)
                                } else if item.type == .manga {
                                    MangaGridItem(id: item.id, title: item.title, enTitle: item.enTitle, imageUrl: item.imageUrl, subtitle: item.relation)
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
