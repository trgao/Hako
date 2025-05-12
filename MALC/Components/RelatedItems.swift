//
//  RelatedItems.swift
//  MALC
//
//  Created by Gao Tianrun on 6/5/24.
//

import SwiftUI

struct RelatedItem: Codable, Identifiable {
    var id: Int { malId }
    let malId: Int
    let type: TypeEnum?
    let name: String?
    let url: String?
    let relation: String?
}

struct RelatedItems: View {
    private let relations: [Related]?
    private var relationsPrefix: [RelatedItem] = []
    
    init(relations: [Related]?) {
        self.relations = relations
        var count = 0
        if let relations = relations {
            for category in relations {
                for item in category.entry {
                    if count < 10 {
                        let currentItem = RelatedItem(malId: item.malId, type: item.type, name: item.name, url: item.url, relation: category.relation)
                        relationsPrefix.append(currentItem)
                        count += 1
                    }
                }
            }
        }
    }
    
    var body: some View {
        if let relations = relations {
            if !relations.isEmpty {
                VStack {
                    NavigationLink {
                        RelatedItemsListView(relations: relations)
                    } label: {
                        HStack {
                            Text("Related")
                                .bold()
                            Image(systemName: "chevron.right")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 15)
                        .font(.system(size: 17))
                    }
                    .buttonStyle(.plain)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            Rectangle()
                                .frame(width: 10)
                                .foregroundColor(.clear)
                            ForEach(relationsPrefix) { item in
                                NavigationLink {
                                    if item.type == .anime {
                                        AnimeDetailsView(id: item.id, imageUrl: nil)
                                    } else if item.type == .manga {
                                        MangaDetailsView(id: item.id, imageUrl: nil)
                                    }
                                } label: {
                                    if item.type == .anime {
                                        AnimeGridItem(id: item.id, title: item.name, imageUrl: nil, subtitle: item.relation)
                                    } else if item.type == .manga {
                                        MangaGridItem(id: item.id, title: item.name, imageUrl: nil, subtitle: item.relation)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            Rectangle()
                                .frame(width: 10)
                                .foregroundColor(.clear)
                        }
                        .padding(2)
                    }
                }
            }
        }
    }
}
