//
//  ListFilter.swift
//  MALC
//
//  Created by Gao Tianrun on 18/5/24.
//

import SwiftUI

struct ListFilter: View {
    @StateObject var controller: MyListViewController
    
    init(controller: MyListViewController) {
        self._controller = StateObject(wrappedValue: controller)
    }
    
    var body: some View {
        Menu {
            if controller.type == .anime {
                Picker(selection: $controller.animeStatus, label: EmptyView()) {
                    Label("All", systemImage: "circle.circle").tag(StatusEnum.none)
                    Label("Watching", systemImage: "play.circle").tag(StatusEnum.watching)
                    Label("Completed", systemImage: "checkmark.circle").tag(StatusEnum.completed)
                    Label("On hold", systemImage: "pause.circle").tag(StatusEnum.onHold)
                    Label("Dropped", systemImage: "minus.circle").tag(StatusEnum.dropped)
                    Label("Plan to watch", systemImage: "plus.circle.dashed").tag(StatusEnum.planToWatch)
                }
                .onChange(of: controller.animeStatus) { _ in
                    Task {
                        await controller.refresh(true)
                    }
                }
                Divider()
                Picker(selection: $controller.animeSort, label: EmptyView()) {
                    Label("By score", systemImage: "star").tag("list_score")
                    Label("By last update", systemImage: "arrow.trianglehead.clockwise.rotate.90").tag("list_updated_at")
                    Label("By title", systemImage: "character").tag("anime_title")
                    Label("By start date", systemImage: "calendar").tag("anime_start_date")
                }
                .onChange(of: controller.animeSort) { _ in
                    Task {
                        await controller.refresh(true)
                    }
                }
            } else if controller.type == .manga {
                Picker(selection: $controller.mangaStatus, label: EmptyView()) {
                    Label("All", systemImage: "circle.circle").tag(StatusEnum.none)
                    Label("Reading", systemImage: "book.circle").tag(StatusEnum.reading)
                    Label("Completed", systemImage: "checkmark.circle").tag(StatusEnum.completed)
                    Label("On hold", systemImage: "pause.circle").tag(StatusEnum.onHold)
                    Label("Dropped", systemImage: "minus.circle").tag(StatusEnum.dropped)
                    Label("Plan to read", systemImage: "plus.circle.dashed").tag(StatusEnum.planToRead)
                }
                .onChange(of: controller.mangaStatus) { _ in
                    Task {
                        await controller.refresh(true)
                    }
                }
                Divider()
                Picker(selection: $controller.mangaSort, label: EmptyView()) {
                    Label("By score", systemImage: "star").tag("list_score")
                    Label("By last Update", systemImage: "arrow.trianglehead.clockwise.rotate.90").tag("list_updated_at")
                    Label("By title", systemImage: "character").tag("manga_title")
                    Label("By start date", systemImage: "calendar").tag("manga_start_date")
                }
                .onChange(of: controller.mangaSort) { _ in
                    Task {
                        await controller.refresh(true)
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
