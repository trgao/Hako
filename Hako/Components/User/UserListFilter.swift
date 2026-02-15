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
            if !settings.useStatusTabBar {
                Picker("Status", selection: controller.type == .anime ? $controller.animeStatus : $controller.mangaStatus) {
                    ForEach(controller.type == .anime ? Constants.animeStatuses : Constants.mangaStatuses, id: \.self) { status in
                        Label(status.toString(), systemImage: status.toIcon()).tag(status)
                    }
                }
                .pickerStyle(.inline)
                Divider()
            }
            Picker("Sort", selection: controller.type == .anime ? $controller.animeSort : $controller.mangaSort) {
                ForEach(controller.type == .anime ? Constants.animeSorts : Constants.mangaSorts, id: \.self) { sort in
                    Label(sort.toString(), systemImage: sort.toIcon()).tag(sort)
                }
            }
            .pickerStyle(.inline)
        } label: {
            Label("Menu", systemImage: settings.useStatusTabBar ? "arrow.up.arrow.down.circle" : "line.3.horizontal.decrease.circle")
                .labelStyle(.iconOnly)
        }
        .disabled(controller.isLoading())
    }
}
