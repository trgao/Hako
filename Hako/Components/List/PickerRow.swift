//
//  PickerRow.swift
//  Hako
//
//  Created by Gao Tianrun on 16/5/25.
//

import SwiftUI

struct PickerRow: View {
    @Binding var selection: Int
    var title: String
    var labels: [String]
    
    init(title: String, selection: Binding<Int>, labels: [String]) {
        self._selection = selection
        self.title = title
        self.labels = labels
    }
    
    private var menu: some View {
        Menu {
            ForEach(labels.indices, id: \.self) { index in
                if !labels[index].isEmpty {
                    Button {
                        selection = index
                    } label: {
                        if selection == index {
                            HStack {
                                Image(systemName: "checkmark")
                                Text(labels[index])
                            }
                        } else {
                            Text(labels[index])
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(labels[selection])
                Image(systemName: "chevron.down")
                    .font(.system(size: 13))
            }
        }
    }
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(Color.primary)
            Spacer()
            menu
        }
    }
}
