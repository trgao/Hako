//
//  RelatedItems.swift
//  MALC
//
//  Created by Gao Tianrun on 6/5/24.
//

import SwiftUI

struct RelatedItems: View {
    @StateObject private var controller: RelatedItemsController
    
    init(id: Int, type: TypeEnum) {
        self._controller = StateObject(wrappedValue: RelatedItemsController(id: id, type: type))
    }
    
    var body: some View {
        if !controller.isLoading && !controller.items.isEmpty {
            Section {} header: {
                VStack {
                    NavigationLink {
                        RelatedItemsListView(controller: controller)
                    } label: {
                        HStack {
                            Text("Related")
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color(.systemGray2))
                        }
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 30)
                        .font(.system(size: 17))
                    }
                    .buttonStyle(.plain)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            Rectangle()
                                .frame(width: 5)
                                .foregroundColor(.clear)
                            ForEach(controller.items.prefix(10)) { item in
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
