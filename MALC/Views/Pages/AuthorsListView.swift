//
//  AuthorsListView.swift
//  MALC
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct AuthorsListView: View {
    private let authors: [Author]
    
    init(authors: [Author]) {
        self.authors = authors
    }
    
    var body: some View {
        ZStack {
            List {
                ForEach(authors) { author in
                    NavigationLink {
                        PersonDetailsView(id: author.id)
                    } label: {
                        HStack {
                            ImageFrame(id: "person\(author.id)", imageUrl: author.imageUrl, imageSize: .small)
                                .padding([.trailing], 10)
                            VStack(alignment: .leading) {
                                Text("\(author.node.firstName ?? "") \(author.node.lastName ?? "")")
                                Text(author.role ?? "")
                                    .foregroundStyle(Color(.systemGray))
                                    .font(.system(size: 13))
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Authors")
            .background(Color(.secondarySystemBackground))
        }
    }
}
