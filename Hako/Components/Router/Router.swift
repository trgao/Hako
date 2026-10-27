//
//  Router.swift
//  Hako
//
//  Created by Gao Tianrun on 23/10/26.
//

import SwiftUI

@Observable
@MainActor
final class Router {
    var path = NavigationPath()
    var userListPresentedPath: [Bool] = []
    var isUserListPresented: Bool {
        if userListPresentedPath.count < path.count || userListPresentedPath.isEmpty || path.isEmpty {
            return false
        } else {
            return userListPresentedPath[path.count - 1]
        }
    }
    var isRoot: Bool {
        path.isEmpty
    }

    // User list view states
    var pickerType: TypeEnum = .anime
    var pickerAnimeStatus: StatusEnum = .watching
    var pickerMangaStatus: StatusEnum = .reading
    var pickerDisabled = false

    func push<Item: Hashable>(_ item: Item) {
        userListPresentedPath = Array(userListPresentedPath.prefix(path.count))
        userListPresentedPath.append(item is UserList)
        path.append(item)
        if isUserListPresented {
            pickerType = .anime
            pickerAnimeStatus = .watching
            pickerMangaStatus = .reading
            pickerDisabled = false
        }
    }

    func pop() {
        guard !path.isEmpty else {
            return
        }
        path.removeLast()
        userListPresentedPath = Array(userListPresentedPath.prefix(path.count))
    }

    func popToRoot() {
        // Resets the stack entirely
        path = NavigationPath()
        userListPresentedPath = []
    }

    func restartWith<Item: Hashable>(_ item: Item) {
        popToRoot()
        push(item)
    }
}
