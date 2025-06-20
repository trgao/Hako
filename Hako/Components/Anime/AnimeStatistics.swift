//
//  AnimeStatistics.swift
//  Hako
//
//  Created by Gao Tianrun on 13/5/25.
//

import SwiftUI

struct AnimeStatistics: View {
    @StateObject private var controller: AnimeDetailsViewController
    
    init(controller: AnimeDetailsViewController) {
        self._controller = StateObject(wrappedValue: controller)
    }
    
    var body: some View {
        ScrollViewSection(title: "Statistics") {
            StatisticsRow(title: "All", content: controller.statistics?.total, icon: "circle.circle", color: .primary)
            StatisticsRow(title: "Watching", content: controller.statistics?.watching, icon: "play.circle", color: .blue)
            StatisticsRow(title: "Completed", content: controller.statistics?.completed, icon: "checkmark.circle", color: .green)
            StatisticsRow(title: "On hold", content: controller.statistics?.onHold, icon: "pause.circle", color: .yellow)
            StatisticsRow(title: "Dropped", content: controller.statistics?.dropped, icon: "minus.circle", color: .red)
            StatisticsRow(title: "Plan to watch", content: controller.statistics?.planToWatch, icon: "plus.circle.dashed", color: .purple)
        }
    }
}
