//
//  MangaStatistics.swift
//  MALC
//
//  Created by Gao Tianrun on 13/5/25.
//

import SwiftUI

struct MangaStatistics: View {
    @StateObject private var controller: MangaStatisticsController
    
    init(id: Int) {
        self._controller = StateObject(wrappedValue: MangaStatisticsController(id: id))
    }
    
    var body: some View {
        if let statistics = controller.statistics {
            Section {
                ListRow(title: "All", content: String(statistics.total), icon: "circle.circle", color: .primary)
                ListRow(title: "Reading", content: String(statistics.reading), icon: "book.circle", color: .blue)
                ListRow(title: "Completed", content: String(statistics.completed), icon: "checkmark.circle", color: .green)
                ListRow(title: "On hold", content: String(statistics.onHold), icon: "pause.circle", color: .yellow)
                ListRow(title: "Dropped", content: String(statistics.dropped), icon: "minus.circle", color: .red)
                ListRow(title: "Plan to read", content: String(statistics.planToRead), icon: "plus.circle.dashed", color: .purple)
            } header: {
                Text("Statistics")
                    .textCase(nil)
                    .foregroundColor(Color.primary)
                    .font(.system(size: 17))
                    .bold()
            }
            .alignmentGuide(.listRowSeparatorLeading) { _ in
                return -20
            }
        }
    }
}
