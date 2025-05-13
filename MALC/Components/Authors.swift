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
    
    init(authors: [Author]) {
        self._controller = StateObject(wrappedValue: AuthorsController(authors: authors))
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
                                .bold()
                            Image(systemName: "chevron.right")
                        }
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
                                NavigationLink {
                                    PersonDetailsView(id: author.id)
                                } label: {
                                    VStack {
                                        ImageFrame(id: "person\(author.id)", imageUrl: author.imageUrl, imageSize: .medium)
                                        Text("\(author.node.firstName ?? "") \(author.node.lastName ?? "")")
                                            .font(.system(size: 14))
                                    }
                                    .frame(width: 120)
                                }
                                .buttonStyle(.plain)
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
