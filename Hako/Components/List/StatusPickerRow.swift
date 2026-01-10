//
//  StatusPickerRow.swift
//  Hako
//
//  Created by Gao Tianrun on 7/1/26.
//

import SwiftUI

private func statusToIndex(_ status: StatusEnum?) -> Int {
    switch status {
    case .watching, .reading: return 0
    case .completed: return 1
    case .onHold: return 2
    case .dropped: return 3
    default: return 4
    }
}

struct StatusPickerRow: View {
    @State private var selected: Int
    @Binding var selection: StatusEnum?
    private let labels: [String]
    private let mappings: [StatusEnum?]
    
    init(selection: Binding<StatusEnum?>, type: TypeEnum) {
        self._selection = selection
        self.selected = statusToIndex(selection.wrappedValue)
        if type == .anime {
            self.labels = ["Watching", "Completed", "On hold", "Dropped", "Plan to watch"]
            self.mappings = [.watching, .completed, .onHold, .dropped, .planToWatch]
        } else {
            self.labels = ["Reading", "Completed", "On hold", "Dropped", "Plan to read"]
            self.mappings = [.reading, .completed, .onHold, .dropped, .planToRead]
        }
    }
    
    var body: some View {
        Picker("Status", selection: $selection) {
            ForEach(labels.indices, id: \.self) { index in
                Text(labels[index]).tag(mappings[index])
            }
        }
        .onChange(of: selection) { _, cur in
            selected = statusToIndex(cur)
        }
    }
}
