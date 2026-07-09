//
//  ReviewDetailsView.swift
//  Hako
//
//  Created by Gao Tianrun on 15/6/25.
//

import SwiftUI

struct ReviewDetailsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.screenSize) private var screenSize
    @State private var showTranslation = false
    private var item: Review
    
    init(item: Review) {
        self.item = item
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if let username = item.user?.username, let date = item.date {
                    NavigationLink {
                        UserProfileView(user: username)
                    } label: {
                        HStack {
                            ImageFrame(id: "user\(username)", imageUrl: item.user?.images?.jpg?.imageUrl, imageSize: .reviewUser)
                            Text("\(username) ・ \(date.toString())")
                        }
                    }
                    .buttonStyle(.plain)
                    .font(.caption)
                    .bold()
                    .padding(.bottom, 5)
                }
                HStack {
                    if let recommended = item.tags?.filter({ $0 == "Recommended" || $0 == "Not Recommended" || $0 == "Mixed Feelings" })[0] {
                        TagItem(text: recommended)
                    }
                    Spacer()
                    if let score = item.score, score > 0 {
                        Text("\(score) ⭐")
                            .bold()
                            .font(.subheadline)
                    }
                }
                if let text = item.review {
                    Text(text)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
                        .shadow(radius: 0.5)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
                        .contextMenu {
                            Button {
                                UIPasteboard.general.string = text
                            } label: {
                                Label("Copy", systemImage: "document.on.document")
                            }
                            if !ProcessInfo.processInfo.isMacCatalystApp {
                                Button {
                                    showTranslation = true
                                } label: {
                                    Label("Translate", systemImage: "translate")
                                }
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
            ShareLink(item: URL(string: "https://myanimelist.net/reviews.php?id=\(item.id)")!) {
                Image(systemName: "square.and.arrow.up")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Review")
    }
}
