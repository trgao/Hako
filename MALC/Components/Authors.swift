//
//  Authors.swift
//  MALC
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct Authors: View {
    @StateObject private var controller: AuthorsController
    let networker = NetworkManager.shared
    
    init(id: Int, authors: [Author]?) {
        self._controller = StateObject(wrappedValue: AuthorsController(id: id, authors: authors))
    }
    
    var body: some View {
        if !controller.isLoading && !controller.authors.isEmpty {
            Section {} header: {
                VStack {
                    NavigationLink {
                        AuthorsListView(authors: controller.authors)
                    } label: {
                        HStack {
                            Text("Authors")
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color(.systemGray2))
                        }
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 30)
                        .font(.system(size: 17))
                    }
                    .buttonStyle(.plain)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            Rectangle()
                                .frame(width: 5)
                                .foregroundColor(.clear)
                            ForEach(controller.authors.prefix(10)) { author in
                                ZoomTransition {
                                    PersonDetailsView(id: author.id)
                                } label: {
                                    VStack {
                                        ImageFrame(id: "person\(author.id)", imageUrl: author.imageUrl, imageSize: .medium)
                                        Text("\(author.node.lastName ?? ""), \(author.node.firstName ?? "")")
                                            .font(.system(size: 14))
                                    }
                                    .frame(width: 120)
                                }
                            }
                            Rectangle()
                                .frame(width: 5)
                                .foregroundColor(.clear)
                        }
                    }
                    
                }
                .textCase(nil)
                .padding(.horizontal, -15)
                .foregroundColor(Color.primary)
                .listRowInsets(.init())
            }
            .listRowInsets(.init())
        }
    }
}
