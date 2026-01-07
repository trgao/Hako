//
//  StatusPickerRow.swift
//  Hako
//
//  Created by Gao Tianrun on 7/1/26.
//

import SwiftUI

private func statusToIndex(_ status: StatusEnum?) -> Int {
    if status == .watching || status == .reading {
        return 0
    } else if status == .completed {
        return 1
    } else if status == .onHold {
        return 2
    } else if status == .dropped {
        return 3
    } else {
        return 4
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
    
    private var menu: some View {
        Menu {
            ForEach(labels.indices, id: \.self) { index in
                Button {
                    selected = index
                    selection = mappings[index]
                } label: {
                    if selected == index {
                        HStack {
                            Image(systemName: "checkmark")
                            Text(labels[index])
                        }
                    } else {
                        Text(labels[index])
                    }
                }
            }
        } label: {
            HStack {
                Text(labels[selected])
                Image(systemName: "chevron.down")
                    .font(.system(size: 13))
            }
        }
        .onChange(of: selection) { _, cur in
            selected = statusToIndex(cur)
        }
    }
    
    var body: some View {
        HStack {
            Text("Status")
                .foregroundStyle(Color.primary)
            Spacer()
            menu
        }
    }
}
