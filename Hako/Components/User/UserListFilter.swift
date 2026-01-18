//
//  UserListFilter.swift
//  Hako
//
//  Created by Gao Tianrun on 16/1/26.
//

import SwiftUI

struct UserListFilter: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller: UserListViewController
    
    init(controller: UserListViewController) {
        self._controller = StateObject(wrappedValue: controller)
    }
    
    var body: some View {
        Menu {
            if controller.type == .anime {
                if settings.hideStatusPicker {
                    Picker(selection: $controller.animeStatus, label: Text("Status")) {
                        Label("All", systemImage: "circle.circle").tag(StatusEnum.none)
                        Label("Watching", systemImage: "play.circle").tag(StatusEnum.watching)
                        Label("Completed", systemImage: "checkmark.circle").tag(StatusEnum.completed)
                        Label("On hold", systemImage: "pause.circle").tag(StatusEnum.onHold)
                        Label("Dropped", systemImage: "minus.circle").tag(StatusEnum.dropped)
                        Label("Plan to watch", systemImage: "plus.circle.dashed").tag(StatusEnum.planToWatch)
                    }
                    Divider()
                }
                Picker(selection: $controller.animeSort, label: Text("Sort")) {
                    Label("By score", systemImage: "star").tag(SortEnum.listScore)
                    Label("By last update", systemImage: "arrow.trianglehead.clockwise.rotate.90").tag(SortEnum.listUpdatedAt)
                    Label("By title", systemImage: "character").tag(SortEnum.animeTitle)
                    Label("By start date", systemImage: "calendar").tag(SortEnum.animeStartDate)
                }
            } else if controller.type == .manga {
                if settings.hideStatusPicker {
                    Picker(selection: $controller.mangaStatus, label: Text("Status")) {
                        Label("All", systemImage: "circle.circle").tag(StatusEnum.none)
                        Label("Reading", systemImage: "book.circle").tag(StatusEnum.reading)
                        Label("Completed", systemImage: "checkmark.circle").tag(StatusEnum.completed)
                        Label("On hold", systemImage: "pause.circle").tag(StatusEnum.onHold)
                        Label("Dropped", systemImage: "minus.circle").tag(StatusEnum.dropped)
                        Label("Plan to read", systemImage: "plus.circle.dashed").tag(StatusEnum.planToRead)
                    }
                    Divider()
                }
                Picker(selection: $controller.mangaSort, label: Text("Sort")) {
                    Label("By score", systemImage: "star").tag(SortEnum.listScore)
                    Label("By last update", systemImage: "arrow.trianglehead.clockwise.rotate.90").tag(SortEnum.listUpdatedAt)
                    Label("By title", systemImage: "character").tag(SortEnum.mangaTitle)
                    Label("By start date", systemImage: "calendar").tag(SortEnum.mangaStartDate)
                }
            }
        } label: {
            Image(systemName: settings.hideStatusPicker ? "line.3.horizontal.decrease.circle" : "arrow.up.arrow.down.circle")
        }
        .disabled(controller.isLoading())
    }
}
