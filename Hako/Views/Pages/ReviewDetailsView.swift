//
//  ReviewDetailsView.swift
//  Hako
//
//  Created by Gao Tianrun on 15/6/25.
//

import SwiftUI

struct ReviewDetailsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var showTranslation = false
    private var item: Review
    private let url: URL
    
    init(item: Review) {
        self.item = item
        self.url = URL(string: "https://myanimelist.net/reviews.php?id=\(item.id)")!
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if let username = item.user?.username, let date = item.date {
                    NavigationLink {
                        UserListView(user: username)
                    } label: {
                        HStack {
                            ImageFrame(id: "user\(username)", imageUrl: item.user?.images?.jpg?.imageUrl, imageSize: .reviewUser)
                            Text("\(username) ・ \(date.toString())")
                                .font(.system(size: 12))
                                .bold()
                                .padding(5)
                        }
                    }
                    .buttonStyle(.plain)
                }
                if let tags = item.tags {
                    TagCloudView(tags: tags)
                }
                if let text = item.review {
                    Text("\(text)\(item.score != nil ? "\n\nScore: \(item.score, default: "?") / 10" : "")")
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.system(size: 17))
                        .padding(20)
                        .background(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
                        .shadow(radius: 0.5)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .contextMenu {
                            Button {
                                UIPasteboard.general.string = text
                            } label: {
                                Label("Copy", systemImage: "document.on.document")
                            }
                            Button {
                                showTranslation = true
                            } label: {
                                Label("Translate", systemImage: "translate")
                            }
                        }
                        .translationPresentation(isPresented: $showTranslation,
                                                 text: text)
                }
            }
            .padding(17)
        }
        .background {
            ImageFrame(id: "user\(item.user?.username ?? "")", imageUrl: item.user?.images?.jpg?.imageUrl, imageSize: .background)
        }
        .toolbar {
            ShareLink(item: url) {
                Image(systemName: "square.and.arrow.up")
            }
        }
    }
}
