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
        Section {
            ListRow(title: "All", content: controller.statistics?.total, icon: "circle.circle", color: .primary)
            ListRow(title: "Watching", content: controller.statistics?.watching, icon: "play.circle", color: .blue)
            ListRow(title: "Completed", content: controller.statistics?.completed, icon: "checkmark.circle", color: .green)
            ListRow(title: "On hold", content: controller.statistics?.onHold, icon: "pause.circle", color: .yellow)
            ListRow(title: "Dropped", content: controller.statistics?.dropped, icon: "minus.circle", color: .red)
            ListRow(title: "Plan to watch", content: controller.statistics?.planToWatch, icon: "plus.circle.dashed", color: .purple)
        } header: {
            Text("Statistics")
                .textCase(nil)
                .foregroundColor(Color.primary)
                .font(.system(size: 17))
                .bold()
        }
    }
}
