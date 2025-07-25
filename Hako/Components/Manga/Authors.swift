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
        if !controller.authors.isEmpty {
            ScrollViewCarousel(title: "Authors") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 15) {
                        ForEach(controller.authors.prefix(10)) { author in
                            ZoomTransition {
                                PersonDetailsView(id: author.id)
                            } label: {
                                VStack {
                                    ImageFrame(id: "person\(author.id)", imageUrl: author.imageUrl, imageSize: .medium)
                                    Text("\(author.node.lastName ?? "")\(haveBothNames(author.node.firstName, author.node.lastName) ? ", " : "")\(author.node.firstName ?? "")")
                                        .lineLimit(settings.getLineLimit())
                                        .font(.system(size: 14))
                                }
                                .frame(width: 110)
                            }
                        }
                    }
                    .padding(.horizontal, 17)
                }
            }
        }
    }
}
