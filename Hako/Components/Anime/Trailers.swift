//
//  Trailers.swift
//  Hako
//
//  Created by Gao Tianrun on 11/5/24.
//

import SwiftUI
import YouTubePlayerKit

struct Trailers: View {
    @Environment(\.screenRatio) private var screenRatio
    private let videos: [Video]
    private let configuration: YouTubePlayer.Configuration
    
    init(videos: [Video]?) {
        self.videos = videos ?? []
        self.configuration = .init(allowsInlineMediaPlayback: false, allowsPictureInPictureMediaPlayback: true)
    }
    
    var body: some View {
        if !videos.isEmpty {
            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 10) {
                    ForEach(videos) { video in
                        if let url = video.url {
                            YouTubePlayerView(YouTubePlayer(source: YouTubePlayer.Source(urlString: url), configuration: configuration), overlay: { state in
                                switch state {
                                case .idle:
                                    ZStack {
                                        Rectangle()
                                            .foregroundStyle(.black)
                                        ProgressView()
                                    }
                                case .ready, .error(.embeddedVideoPlayingNotAllowed):
                                    EmptyView()
                                case .error:
                                    ZStack {
                                        Rectangle()
                                            .foregroundStyle(.black)
                                        VStack {
                                            Image(systemName: "exclamationmark.triangle")
                                                .padding(.bottom, 5)
                                            Text("Unable to load")
                                                .bold()
                                        }
                                        .foregroundStyle(.white)
                                    }
                                }
                            })
                            .frame(width: 300 * screenRatio, height: 170 * screenRatio)
                            .cornerRadius(10)
                            .padding(5)
                        }
                    }
                }
                .padding(.horizontal, 17)
            }
            .padding(.top, 5)
            .scrollIndicators(.never)
        }
    }
}
