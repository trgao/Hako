//
//  TrailersView.swift
//  Hako
//
//  Created by Gao Tianrun on 11/5/24.
//

import SwiftUI
import YouTubePlayerKit

struct TrailersView: View {
    private let videos: [Video]
    
    init(videos: [Video]) {
        self.videos = videos
    }
    
    var body: some View {
        VStack(alignment: .center) {
            ScrollView {
                ForEach(videos) { video in
                    YoutubeVideo(url: video.url)
                }
            }
            .scrollIndicators(.hidden)
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
        if let url = url {
            YouTubePlayerView(YouTubePlayer(urlString: url), overlay: { state in
                switch state {
                case .idle:
                    ZStack {
                        Rectangle()
                            .foregroundStyle(.black)
                        ProgressView()
                    }
                default:
                    EmptyView()
                }
            })
                .frame(width: 300, height: 170)
                .cornerRadius(10)
                .shadow(radius: 2)
                .padding(5)
        }
    }
}
