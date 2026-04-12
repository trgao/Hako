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
    private let players: [YouTubePlayer]
    
    init(videos: [Video]?) {
        let configuration = YouTubePlayer.Configuration(allowsInlineMediaPlayback: false, allowsPictureInPictureMediaPlayback: true)
        self.players = videos?.compactMap { video in
            guard let url = video.url else {
                return nil
            }
            return YouTubePlayer(source: .init(urlString: url), configuration: configuration)
        } ?? []
    }
    
    var body: some View {
        if !players.isEmpty {
            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 10) {
                    ForEach(players) { player in
                        YouTubePlayerView(player, overlay: { state in
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
                                        Button {
                                            Task {
                                                try await player.reload()
                                            }
                                        } label: {
                                            Image(systemName: "arrow.clockwise")
                                        }
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
                .padding(.horizontal, 17)
            }
            .padding(.top, 5)
            .scrollIndicators(.never)
        }
    }
}
