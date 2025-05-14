//
//  MangaStatistics.swift
//  MALC
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
        Section {
            ListRow(title: "All", content: controller.statistics?.total, icon: "circle.circle", color: .primary)
            ListRow(title: "Reading", content: controller.statistics?.reading, icon: "book.circle", color: .blue)
            ListRow(title: "Completed", content: controller.statistics?.completed, icon: "checkmark.circle", color: .green)
            ListRow(title: "On hold", content: controller.statistics?.onHold, icon: "pause.circle", color: .yellow)
            ListRow(title: "Dropped", content: controller.statistics?.dropped, icon: "minus.circle", color: .red)
            ListRow(title: "Plan to read", content: controller.statistics?.planToRead, icon: "plus.circle.dashed", color: .purple)
        } header: {
            Text("Statistics")
                .textCase(nil)
                .foregroundColor(Color.primary)
                .font(.system(size: 17))
                .bold()
        }
    }
}
