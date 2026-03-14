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
    @Environment(\.scenePhase) private var scenePhase
    private let videos: [Video]
    
    init(videos: [Video]?) {
        self.videos = videos ?? []
    }
    
    var body: some View {
        VStack {
            if !videos.isEmpty {
                ScrollViewCarousel(title: "Trailers") {
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
            }
        }
    }
}
