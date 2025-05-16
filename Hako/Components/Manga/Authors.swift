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
    
    var body: some View {
        if !controller.authors.isEmpty {
            Section {} header: {
                VStack {
                    Text("Authors")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 35)
                        .font(.system(size: 17))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            ForEach(controller.authors.prefix(10)) { author in
                                ZoomTransition {
                                    PersonDetailsView(id: author.id)
                                } label: {
                                    VStack {
                                        ImageFrame(id: "person\(author.id)", imageUrl: author.imageUrl, imageSize: .medium)
                                        Text("\(author.node.lastName ?? ""), \(author.node.firstName ?? "")")
                                            .lineLimit(settings.getLineLimit())
                                            .font(.system(size: 14))
                                    }
                                    .frame(width: 120)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .textCase(nil)
                .padding(.horizontal, -20)
                .foregroundColor(Color.primary)
                .listRowInsets(.init())
            }
            .listRowInsets(.init())
        }
    }
}
