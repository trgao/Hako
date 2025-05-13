//
//  RelatedItems.swift
//  MALC
//
//  Created by Gao Tianrun on 6/5/24.
//

import SwiftUI

struct RelatedItems: View {
    @StateObject private var controller: RelatedItemsController
    
    init(relations: [Related]?) {
        var items: [RelatedItem] = []
        if let relations = relations {
            items = relations.flatMap{ category in category.entry.map{ RelatedItem(malId: $0.malId, type: $0.type, name: $0.name, url: $0.url, relation: category.relation, imageUrl: nil) } }
        }
        self._controller = StateObject(wrappedValue: RelatedItemsController(items: items))
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
                                .bold()
                            Image(systemName: "chevron.right")
                        }
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
                                NavigationLink {
                                    if item.type == .anime {
                                        AnimeDetailsView(id: item.id, imageUrl: item.imageUrl)
                                    } else if item.type == .manga {
                                        MangaDetailsView(id: item.id, imageUrl: item.imageUrl)
                                    }
                                } label: {
                                    if item.type == .anime {
                                        AnimeGridItem(id: item.id, title: item.name, imageUrl: item.imageUrl, subtitle: item.relation)
                                    } else if item.type == .manga {
                                        MangaGridItem(id: item.id, title: item.name, imageUrl: item.imageUrl, subtitle: item.relation)
                                    }
                                }
                                .buttonStyle(.plain)
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
