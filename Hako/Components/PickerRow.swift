//
//  PickerRow.swift
//  Hako
//
//  Created by Gao Tianrun on 16/5/25.
//

import SwiftUI

public struct PickerRow: View {
    @Binding var selected: Int
    var array: [String]
    var title: String
    
    public init(title: String, selected: Binding<Int>, array: [String]) {
        self._selected = selected
        self.array = array
        self.title = title
    }
    
    public var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            menu
        }
    }
    
    var menu: some View {
        Menu {
            ForEach(array.indices, id: \.self) { index in
                Button {
                    selected = index
                } label: {
                    if selected == index {
                        HStack {
                            Image(systemName: "checkmark")
                            Text(array[index])
                        }
                    } else {
                        Text(array[index])
                    }
                }
            }
        } label: {
            Text(array[selected])
        }
    }
}
