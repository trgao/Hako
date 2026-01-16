//
//  UserListFilter.swift
//  Hako
//
//  Created by Gao Tianrun on 16/1/26.
//

import SwiftUI

struct UserListFilter: View {
    @StateObject private var controller: UserListViewController
    
    init(controller: UserListViewController) {
        self._controller = StateObject(wrappedValue: controller)
    }
    
    var body: some View {
        Menu {
            if controller.type == .anime {
                Picker(selection: $controller.animeStatus, label: Text("Status")) {
                    Label("All", systemImage: "circle.circle").tag(StatusEnum.none)
                    Label("Watching", systemImage: "play.circle").tag(StatusEnum.watching)
                    Label("Completed", systemImage: "checkmark.circle").tag(StatusEnum.completed)
                    Label("On hold", systemImage: "pause.circle").tag(StatusEnum.onHold)
                    Label("Dropped", systemImage: "minus.circle").tag(StatusEnum.dropped)
                    Label("Plan to watch", systemImage: "plus.circle.dashed").tag(StatusEnum.planToWatch)
                }
                .onChange(of: controller.animeStatus) {
                    Task {
                        await controller.refreshAnime()
                    }
                }
                Divider()
                Picker(selection: $controller.animeSort, label: Text("Sort")) {
                    Label("By score", systemImage: "star").tag(SortEnum.listScore)
                    Label("By last update", systemImage: "arrow.trianglehead.clockwise.rotate.90").tag(SortEnum.listUpdatedAt)
                    Label("By title", systemImage: "character").tag(SortEnum.animeTitle)
                    Label("By start date", systemImage: "calendar").tag(SortEnum.animeStartDate)
                }
                .onChange(of: controller.animeSort) {
                    Task {
                        await controller.refreshAnime()
                    }
                }
            } else if controller.type == .manga {
                Picker(selection: $controller.mangaStatus, label: Text("Status")) {
                    Label("All", systemImage: "circle.circle").tag(StatusEnum.none)
                    Label("Reading", systemImage: "book.circle").tag(StatusEnum.reading)
                    Label("Completed", systemImage: "checkmark.circle").tag(StatusEnum.completed)
                    Label("On hold", systemImage: "pause.circle").tag(StatusEnum.onHold)
                    Label("Dropped", systemImage: "minus.circle").tag(StatusEnum.dropped)
                    Label("Plan to read", systemImage: "plus.circle.dashed").tag(StatusEnum.planToRead)
                }
                .onChange(of: controller.mangaStatus) {
                    Task {
                        await controller.refreshManga()
                    }
                }
                Divider()
                Picker(selection: $controller.mangaSort, label: Text("Sort")) {
                    Label("By score", systemImage: "star").tag(SortEnum.listScore)
                    Label("By last update", systemImage: "arrow.trianglehead.clockwise.rotate.90").tag(SortEnum.listUpdatedAt)
                    Label("By title", systemImage: "character").tag(SortEnum.mangaTitle)
                    Label("By start date", systemImage: "calendar").tag(SortEnum.mangaStartDate)
                }
                .onChange(of: controller.mangaSort) {
                    Task {
                        await controller.refreshManga()
                    }
                }
            }
        } label: {
            Button{} label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
            }
        }
        .disabled(controller.isAnimeLoading || controller.isMangaLoading)
    }
}
