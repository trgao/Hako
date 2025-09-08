//
//  TopFilter.swift
//  Hako
//
//  Created by Gao Tianrun on 21/7/25.
//

import SwiftUI

struct TopFilter: View {
    @StateObject var controller: TopViewController
    
    init(controller: TopViewController) {
        self._controller = StateObject(wrappedValue: controller)
    }
    
    var body: some View {
        Menu {
            if controller.type == .anime {
                Picker(selection: $controller.animeRankingType, label: EmptyView()) {
                    Label("All", systemImage: "circle.circle").tag("all")
                    Label("By popularity", systemImage: "popcorn").tag("bypopularity")
                    Label("By favourites", systemImage: "star").tag("favorite")
                }
                Divider()
                Picker(selection: $controller.animeRankingType, label: EmptyView()) {
                    Label("TV", systemImage: "tv").tag("tv")
                    Label("OVA", systemImage: "tv").tag("ova")
                    Label("Movie", systemImage: "movieclapper").tag("movie")
                    Label("Special", systemImage: "sparkles.tv").tag("special")
                }
            } else if controller.type == .manga {
                Picker(selection: $controller.mangaRankingType, label: EmptyView()) {
                    Label("All", systemImage: "circle.circle").tag("all")
                    Label("By popularity", systemImage: "popcorn").tag("bypopularity")
                    Label("By favourites", systemImage: "star").tag("favorite")
                }
                Divider()
                Picker(selection: $controller.mangaRankingType, label: EmptyView()) {
                    Label("Manga", systemImage: "book").tag("manga")
                    Label("Novels", systemImage: "book.closed").tag("novels")
                    Label("One Shots", systemImage: "book.pages").tag("oneshots")
                    Label("Manhwa", systemImage: "book").tag("manhwa")
                    Label("Manhua", systemImage: "book").tag("manhua")
                }
            }
        } label: {
            Button{} label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
            }
        }
        .onChange(of: controller.animeRankingType) {
            Task {
                await controller.refresh()
            }
        }
        .onChange(of: controller.mangaRankingType) {
            Task {
                await controller.refresh()
            }
        }
    }
}
