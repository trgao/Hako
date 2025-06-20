//
//  MangaStatistics.swift
//  Hako
//
//  Created by Gao Tianrun on 13/5/25.
//

import SwiftUI

struct MangaStatistics: View {
    @StateObject private var controller: MangaDetailsViewController
    
    init(controller: MangaDetailsViewController) {
        self._controller = StateObject(wrappedValue: controller)
    }
    
    var body: some View {
        ScrollViewSection(title: "Statistics") {
            StatisticsRow(title: "All", content: controller.statistics?.total, icon: "circle.circle", color: .primary)
            StatisticsRow(title: "Reading", content: controller.statistics?.reading, icon: "book.circle", color: .blue)
            StatisticsRow(title: "Completed", content: controller.statistics?.completed, icon: "checkmark.circle", color: .green)
            StatisticsRow(title: "On hold", content: controller.statistics?.onHold, icon: "pause.circle", color: .yellow)
            StatisticsRow(title: "Dropped", content: controller.statistics?.dropped, icon: "minus.circle", color: .red)
            StatisticsRow(title: "Plan to read", content: controller.statistics?.planToRead, icon: "plus.circle.dashed", color: .purple)
        }
    }
}
