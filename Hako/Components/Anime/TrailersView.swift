//
//  Trailers.swift
//  Hako
//
//  Created by Gao Tianrun on 11/5/24.
//

import SwiftUI
import YouTubePlayerKit

struct Trailers: View {
    @StateObject private var playerManager: YouTubePlayers
    
    init(videos: [Video]?) {
        self._playerManager = StateObject(wrappedValue: YouTubePlayers(videos: videos))
    }
    
    var body: some View {
        if !playerManager.players.isEmpty {
            Section {} header: {
                VStack {
                    Text("Trailers")
                        .bold()
                        .font(.system(size: 17))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 35)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(playerManager.players) { player in
                                YouTubePlayerView(player)
                                    .frame(width: 300, height: 170)
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                                    .padding(5)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .textCase(nil)
                .padding(.horizontal, -20)
                .foregroundColor(Color.primary)
                .listRowInsets(.init())
            }
            .listRowInsets(.init())
        }
    }
}

@MainActor
class YouTubePlayers: ObservableObject {
    var players: [YouTubePlayer]
    
    init(videos: [Video]?) {
        self.players = (videos ?? []).filter{ $0.url != nil }.map{ YouTubePlayer(urlString: $0.url!) }
    }
}

struct YouTubeVideo: View {
    @StateObject private var player: YouTubePlayer
    let url: String?
    
    init(url: String?) {
        self.url = url
        if let url = url {
            self._player = StateObject(wrappedValue: YouTubePlayer(urlString: url))
        } else {
            self._player = StateObject(wrappedValue: YouTubePlayer())
        }
    }
    
    var body: some View {
        if let _ = url {
            YouTubePlayerView(player)
                .frame(width: 300, height: 170)
                .cornerRadius(10)
                .shadow(radius: 2)
                .padding(5)
        }
    }
}
