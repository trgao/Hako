//
//  NewsListView.swift
//  Hako
//
//  Created by Gao Tianrun on 1/12/25.
//

import SwiftUI

struct NewsListView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller = NewsListViewController()
    
    var body: some View {
        ZStack {
            if controller.isLoadingError {
                ErrorView(refresh: controller.refresh)
            } else {
                List {
                    ForEach(controller.news.filter{ URL(string: $0.link ?? "") != nil }, id: \.hashValue) { item in
                        if let link = item.link {
                            Link(destination: URL(string: link)!) {
                                HStack {
                                    ImageFrame(id: "news\(item.hashValue)", imageUrl: item.media?.thumbnails?.first?.text, imageSize: .small)
                                    VStack(alignment: .leading) {
                                        Text(item.title ?? "")
                                            .lineLimit(settings.getLineLimit())
                                            .bold()
                                            .font(.system(size: 16))
                                            .foregroundStyle(Color.primary)
                                        Text(item.pubDate?.toString() ?? "")
                                            .opacity(0.7)
                                            .font(.system(size: 13))
                                            .padding(.top, 1)
                                            .foregroundStyle(Color.primary)
                                    }
                                    .padding(5)
                                }
                                .contextMenu {
                                    ShareLink(item: URL(string: link)!) {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if controller.isLoading {
                LoadingView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("News")
        .handleOpenURLInApp()
    }
}
