//
//  TrailersView.swift
//  MALC
//
//  Created by Gao Tianrun on 11/5/24.
//

import SwiftUI
import WebKit

struct TrailersView: View {
    private let videos: [Video]?
    
    init(videos: [Video]?) {
        self.videos = videos
    }
    
    var body: some View {
        VStack(alignment: .center) {
            if let videos = videos, !videos.isEmpty {
                ScrollView {
                    ForEach(videos) { video in
                        YoutubeVideo(url: video.url)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Trailers")
        .background(Color(.secondarySystemBackground))
    }
}

struct YoutubeVideo: View {
    let url: String?
    
    init(url: String?) {
        self.url = url
    }
    
    var body: some View {
        YoutubeVideoFrame(url: url)
            .frame(width: 300, height: 170)
            .cornerRadius(10)
            .shadow(radius: 2)
            .padding(5)
    }
}

struct YoutubeVideoFrame: UIViewRepresentable {
    let url: String?
    
    init(url: String?) {
        self.url = url
    }
    
    func makeUIView(context: Context) -> some WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard let url = url else {
            return
        }
        uiView.scrollView.isScrollEnabled = false
        let id = url.suffix(11)
        uiView.loadHTMLString("<iframe width=\"300\" height=\"170\" src=\"https://www.youtube.com/embed/\(id)\" title=\"YouTube video player\" frameborder=\"0\" allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share\" referrerpolicy=\"strict-origin-when-cross-origin\" allowfullscreen style=\"position: absolute;top: 0;left: 0;overflow: hidden;\"></iframe>", baseURL: URL(string: "https://youtube.com")!)
        uiView.configuration.userContentController.addUserScript(self.getZoomDisableScript())
    }
    
    private func getZoomDisableScript() -> WKUserScript {
        let source: String = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);"
        return WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }
}
