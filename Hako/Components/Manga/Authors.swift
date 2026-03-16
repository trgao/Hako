//
//  Authors.swift
//  Hako
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct Authors: View {
    private let authors: [Author]?
    private let mangaLoadingState: LoadingEnum
    private let loadingState: LoadingEnum
    private let load: () async -> Void
    
    init(authors: [Author]?, mangaLoadingState: LoadingEnum, loadingState: LoadingEnum, load: @escaping () async -> Void) {
        self.authors = authors
        self.mangaLoadingState = mangaLoadingState
        self.loadingState = loadingState
        self.load = load
    }
    
    private func haveBothNames(_ firstName: String?, _ lastName: String?) -> Bool {
        return (firstName != nil && firstName != "") && (lastName != nil && lastName != "")
    }
    
    var body: some View {
        ScrollViewCarousel(title: "Authors", count: authors?.count, loadingState: loadingState, refresh: load, placeholder: SmallPlaceholderGridItem.init) {
            ForEach((authors ?? []).prefix(10)) { author in
                PersonGridItem(id: author.id, name: "\(author.node.lastName ?? "")\(haveBothNames(author.node.firstName, author.node.lastName) ? ", " : "")\(author.node.firstName ?? "")", imageUrl: author.imageUrl)
            }
        }
        .task(id: mangaLoadingState) {
            await load()
        }
    }
}
