//
//  RelatedGridView.swift
//  Hako
//
//  Created by Gao Tianrun on 21/3/26.
//

import SwiftUI

struct RelatedGridView: View {
    @Environment(\.screenRatio) private var screenRatio
    @State private var type: String?
    @State private var filteredAnime: [RelatedItem] = []
    @State private var filteredManga: [RelatedItem] = []
    private let relatedAnime: [RelatedItem]?
    private let relatedManga: [RelatedItem]?
    private var types: Set<String> = []
    
    init(relatedAnime: [RelatedItem]?) {
        self.relatedAnime = relatedAnime
        self.relatedManga = nil
        relatedAnime?.forEach {
            if let type = $0.relation {
                types.insert(type)
            }
        }
    }
    
    init(relatedManga: [RelatedItem]?) {
        self.relatedAnime = nil
        self.relatedManga = relatedManga
        relatedManga?.forEach {
            if let type = $0.relation {
                types.insert(type)
            }
        }
    }
    
    var body: some View {
        ScrollView {
            if let type = type {
                Text(type)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(Color(.systemGray))
                    .bold()
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150 * screenRatio), spacing: 5, alignment: .top)]) {
                if relatedAnime != nil {
                    ForEach(filteredAnime) { item in
                        AnimeGridItem(id: item.id, title: item.title, enTitle: item.anime?.alternativeTitles?.en, imageUrl: item.anime?.mainPicture?.large, subtitle: item.relation, anime: item.anime)
                    }
                } else if relatedManga != nil {
                    ForEach(filteredManga) { item in
                        MangaGridItem(id: item.id, title: item.title, enTitle: item.manga?.alternativeTitles?.en, imageUrl: item.manga?.mainPicture?.large, subtitle: item.relation, manga: item.manga)
                    }
                }
            }
            .padding(10)
        }
        .id(type)
        .navigationTitle("Related")
        .toolbar {
            Menu {
                Picker("Type", selection: $type) {
                    Text("All").tag(nil as String?)
                    ForEach(types.sorted(), id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(.inline)
            } label: {
                Label("Menu", systemImage: "line.3.horizontal.decrease.circle")
                    .labelStyle(.iconOnly)
            }
            .onAppear {
                if let relatedAnime = relatedAnime {
                    filteredAnime = relatedAnime
                } else if let relatedManga = relatedManga {
                    filteredManga = relatedManga
                }
            }
            .onChange(of: type) {
                filteredAnime = relatedAnime?.filter { type == nil || $0.relation == type } ?? []
                filteredManga = relatedManga?.filter { type == nil || $0.relation == type } ?? []
            }
        }
    }
}
