//
//  Trailers.swift
//  Hako
//
//  Created by Gao Tianrun on 11/5/24.
//

import SwiftUI
import YouTubePlayerKit
import Combine

struct Trailers: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var players: [YouTubePlayer] = []
    private let videos: [Video]
    
    init(videos: [Video]?) {
        self.videos = videos ?? []
    }
    
    var body: some View {
        VStack {
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
                                                Image(systemName: "exclamationmark.triangle")
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
                                .padding(5)
                            }
                        }
                        .padding(.horizontal, 17)
                    }
                }
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .background {
                self.players = players.map{ _ in YouTubePlayer(urlString: "") }
            } else {
                self.players = videos.filter{ $0.url != nil }.map{ YouTubePlayer(urlString: $0.url!) }
            }
        }
        .onChange(of: videos) {
            self.players = videos.filter{ $0.url != nil }.map{ YouTubePlayer(urlString: $0.url!) }
        }
    }
}
