//
//  AnimeProgress.swift
//  Hako
//
//  Created by Gao Tianrun on 19/6/25.
//

import SwiftUI

struct AnimeProgress: View {
    private var numEpisodes: Int?
    private var numEpisodesWatched: Int
    private var status: StatusEnum?
    private let colours: [StatusEnum:Color] = [
        .watching: Color(.systemGreen),
        .completed: Color(.systemBlue),
        .onHold: Color(.systemYellow),
        .dropped: Color(.systemRed),
        .planToWatch: .primary,
        .none: Color(.systemGray)
    ]
    
    init(numEpisodes: Int?, numEpisodesWatched: Int, status: StatusEnum?) {
        self.numEpisodes = numEpisodes
        self.numEpisodesWatched = numEpisodesWatched
        self.status = status
    }
    
    var body: some View {
        Section {
            if let numEpisodes = numEpisodes, numEpisodes > 0 {
                VStack {
                    ProgressView(value: Float(numEpisodesWatched) / Float(numEpisodes))
                        .tint(colours[status ?? .none])
                    HStack {
                        Text(status?.toString() ?? "")
                            .bold()
                        Spacer()
                        Label("\(String(numEpisodesWatched)) / \(String(numEpisodes))", systemImage: "video.fill")
                            .labelStyle(CustomLabel(spacing: 2))
                    }
                }
                .padding(.vertical, 10)
            } else {
                VStack {
                    ProgressView(value: numEpisodesWatched == 0 ? 0 : 0.5)
                        .tint(colours[status ?? .none])
                    HStack {
                        Text(status?.toString() ?? "")
                            .bold()
                        Spacer()
                        Label("\(String(numEpisodesWatched)) / ?", systemImage: "video.fill")
                            .labelStyle(CustomLabel(spacing: 2))
                    }
                }
                .padding(.vertical, 10)
            }
        } header: {
            Text("Your progress")
                .textCase(nil)
                .foregroundColor(Color.primary)
                .font(.system(size: 17))
                .bold()
                .listRowInsets(.init())
                .padding(.horizontal, 15)
                .padding(.vertical, 5)
        }
    }
}
