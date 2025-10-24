//
//  Authors.swift
//  Hako
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct Authors: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller: MangaDetailsViewController
    let networker = NetworkManager.shared
    
    init(controller: MangaDetailsViewController) {
        self._controller = StateObject(wrappedValue: controller)
    }
    
    private func haveBothNames(_ firstName: String?, _ lastName: String?) -> Bool {
        return (firstName != nil && firstName != "") && (lastName != nil && lastName != "")
    }
    
    var body: some View {
        VStack {
            if !controller.authors.isEmpty {
                ScrollViewCarousel(title: "Authors") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 15) {
                            ForEach(controller.authors.prefix(10)) { author in
                                PersonGridItem(id: author.id, name: "\(author.node.lastName ?? "")\(haveBothNames(author.node.firstName, author.node.lastName) ? ", " : "")\(author.node.firstName ?? "")", imageUrl: author.imageUrl)
                            }
                        }
                        .padding(.horizontal, 17)
                    }
                }
            }
        }
        .task {
            await controller.loadAuthors()
        }
    }
}
