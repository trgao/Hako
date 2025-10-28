//
//  Trailers.swift
//  Hako
//
//  Created by Gao Tianrun on 11/5/24.
//

import SwiftUI
import YouTubePlayerKit

struct Trailers: View {
    private let players: [YouTubePlayer]
    
    init(videos: [Video]?) {
        var youtubePlayers: [YouTubePlayer] = []
        for v in videos ?? [] {
            if let url = v.url {
                youtubePlayers.append(YouTubePlayer(urlString: url))
            }
        }
        self.players = youtubePlayers
    }
    
    var body: some View {
        if !players.isEmpty {
            ScrollViewCarousel(title: "Trailers") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(players) { player in
                            YouTubePlayerView(player, overlay: { state in
                                switch state {
                                case .idle:
                                    ZStack {
                                        Rectangle()
                                            .foregroundStyle(.black)
                                        ProgressView()
                                    }
                                case .ready:
                                    EmptyView()
                                case .error(.embeddedVideoPlayingNotAllowed):
                                    EmptyView()
                                case .error:
                                    ZStack {
                                        Rectangle()
                                            .foregroundStyle(.black)
                                        VStack {
                                            Image(systemName: "exclamationmark.circle")
                                                .padding(.bottom, 5)
                                            Text("Unable to load")
                                                .bold()
                                        }
                                        .foregroundStyle(.white)
                                    }
                                }
                            })
                            .frame(width: 300, height: 170)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                            .padding(5)
                        }
                    }
                    .padding(.horizontal, 17)
                }
            }
        }
    }
}
