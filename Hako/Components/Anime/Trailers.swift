//
//  Trailers.swift
//  Hako
//
//  Created by Gao Tianrun on 11/5/24.
//

import SwiftUI
import YouTubePlayerKit

struct Trailers: View {
    private let videos: [Video]
    
    init(videos: [Video]?) {
        self.videos = videos ?? []
    }
    
    var body: some View {
        if !videos.isEmpty {
            ScrollViewCarousel(title: "Trailers") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(videos) { video in
                            if let url = video.url {
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
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}
