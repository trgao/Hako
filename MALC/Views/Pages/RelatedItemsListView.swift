//
//  RelatedItemsListView.swift
//  MALC
//
//  Created by Gao Tianrun on 11/5/24.
//

import SwiftUI

struct RelatedItemsListView: View {
    private let relations: [Related]
    
    init(relations: [Related]) {
        self.relations = relations
    }
    
    var body: some View {
        ZStack {
            List {
                ForEach(relations, id: \.relation) { category in
                    ForEach(category.entry) { item in
                        NavigationLink {
                            if item.type == .anime {
                                AnimeDetailsView(id: item.id, imageUrl: item.images?.jpg.imageUrl)
                            } else if item.type == .manga {
                                MangaDetailsView(id: item.id, imageUrl: item.images?.jpg.imageUrl)
                            }
                        } label: {
                            HStack {
                                if item.type == .anime {
                                    ImageFrame(id: "anime\(item.id)", imageUrl: item.images?.jpg.imageUrl, imageSize: .small)
                                        .padding([.trailing], 10)
                                } else if item.type == .manga {
                                    ImageFrame(id: "manga\(item.id)", imageUrl: item.images?.jpg.imageUrl, imageSize: .small)
                                        .padding([.trailing], 10)
                                }
                                VStack(alignment: .leading) {
                                    Text(item.name ?? "")
                                    Text(category.relation ?? "")
                                        .foregroundStyle(Color(.systemGray))
                                        .font(.system(size: 13))
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Related")
            .background(Color(.systemGray6))
        }
    }
}
