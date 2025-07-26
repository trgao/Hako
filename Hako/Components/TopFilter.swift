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
                    Text("All").tag("all")
                    Text("By popularity").tag("bypopularity")
                    Text("By favourites").tag("favorite")
                }
                .onChange(of: controller.animeRankingType) {
                    Task {
                        await controller.refresh()
                    }
                }
                Divider()
                Picker(selection: $controller.animeRankingType, label: EmptyView()) {
                    Text("TV").tag("tv")
                    Text("OVA").tag("ova")
                    Text("Movie").tag("movie")
                    Text("Special").tag("special")
                }
                .onChange(of: controller.animeRankingType) {
                    Task {
                        await controller.refresh()
                    }
                }
            } else if controller.type == .manga {
                Picker(selection: $controller.mangaRankingType, label: EmptyView()) {
                    Text("All").tag("all")
                    Text("By popularity").tag("bypopularity")
                    Text("By favourites").tag("favorite")
                }
                .onChange(of: controller.mangaRankingType) {
                    Task {
                        await controller.refresh()
                    }
                }
                Divider()
                Picker(selection: $controller.mangaRankingType, label: EmptyView()) {
                    Text("Manga").tag("manga")
                    Text("Novels").tag("novels")
                    Text("One Shots").tag("oneshots")
                    Text("Manhwa").tag("manhwa")
                    Text("Manhua").tag("manhua")
                }
                .onChange(of: controller.mangaRankingType) {
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
        } label: {
            Button{} label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
            }
        }
    }
}
