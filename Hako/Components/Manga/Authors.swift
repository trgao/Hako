//
//  Authors.swift
//  Hako
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct Authors: View {
    private let authors: [Author]?
    private let load: () async -> Void
    
    init(authors: [Author]?, load: @escaping () async -> Void) {
        self.authors = authors
        self.load = load
    }
    
    private func haveBothNames(_ firstName: String?, _ lastName: String?) -> Bool {
        return (firstName != nil && firstName != "") && (lastName != nil && lastName != "")
    }
    
    var body: some View {
        VStack {
            if let authors = authors, !authors.isEmpty {
                ScrollViewCarousel(title: "Authors", placeholder: SmallPlaceholderGridItem.init) {
                    ForEach(authors.prefix(10)) { author in
                        PersonGridItem(id: author.id, name: "\(author.node.lastName ?? "")\(haveBothNames(author.node.firstName, author.node.lastName) ? ", " : "")\(author.node.firstName ?? "")", imageUrl: author.imageUrl)
                    }
                }
            }
        }
        .task(id: authors?.count) {
            await load()
        }
    }
}
