//
//  RelatedItemsListView.swift
//  MALC
//
//  Created by Gao Tianrun on 11/5/24.
//

import SwiftUI

struct RelatedItemsListView: View {
    @StateObject private var controller: RelatedItemsController
    
    init(controller: RelatedItemsController) {
        self._controller = StateObject(wrappedValue: controller)
    }
    
    var body: some View {
        if !controller.isLoading {
            ZStack {
                List {
                    ForEach(controller.items) { item in
                        NavigationLink {
                            if item.type == .anime {
                                AnimeDetailsView(id: item.id, imageUrl: item.imageUrl)
                            } else if item.type == .manga {
                                MangaDetailsView(id: item.id, imageUrl: item.imageUrl)
                            }
                        } label: {
                            HStack {
                                if item.type == .anime {
                                    ImageFrame(id: "anime\(item.id)", imageUrl: item.imageUrl, imageSize: .small)
                                        .padding([.trailing], 10)
                                } else if item.type == .manga {
                                    ImageFrame(id: "manga\(item.id)", imageUrl: item.imageUrl, imageSize: .small)
                                        .padding([.trailing], 10)
                                }
                                VStack(alignment: .leading) {
                                    Text(item.name ?? "")
                                    Text(item.relation ?? "")
                                        .foregroundStyle(Color(.systemGray))
                                        .font(.system(size: 13))
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .navigationTitle("Related")
                .background(Color(.secondarySystemBackground))
            }
        }
    }
}
