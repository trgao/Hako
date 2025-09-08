//
//  AnimeAiringInformation.swift
//  Hako
//
//  Created by Gao Tianrun on 15/6/25.
//

import SwiftUI

struct AnimeAiringSchedule: View {
    @StateObject private var controller: AnimeDetailsViewController
    
    init(controller: AnimeDetailsViewController) {
        self._controller = StateObject(wrappedValue: controller)
    }
    
    var body: some View {
        VStack {
            if let nextEpisode = controller.nextEpisode {
                ScrollViewSection(title: "Airing") {
                    ScrollViewRow(title: "Next episode", content: nextEpisode.episode)
                    ScrollViewRow(title: "Airing at", content: Date(timeIntervalSince1970: TimeInterval(nextEpisode.airingAt)).toFullString())
                }
            }
        }
        .task {
            await controller.loadAiringSchedule()
        }
    }
}
