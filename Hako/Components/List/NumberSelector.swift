//
//  NumberSelector.swift
//  Hako
//
//  Created by Gao Tianrun on 7/10/24.
//

import SwiftUI

struct NumberSelector: View {
    @Binding private var num: Int
    @State private var numString: String
    private let title: String
    private let max: Int?

    init(title: String, num: Binding<Int>, max: Int?) {
        self._num = num
        self.title = title
        self.max = max
        self.numString = String(num.wrappedValue)
    }

    var body: some View {
        if let max, max > 0 && max <= 500 {
            PickerRow(title: title, selection: $num, labels: (0...max).map(String.init))
        } else {
            HStack {
                Text(title)
                TextField("", text: $numString)
                    .keyboardType(.numberPad)
                    .onChange(of: numString) {
                        let filtered = numString.filter { "0123456789".contains($0) }

                        if filtered.isEmpty {
                            numString = "0"
                            num = 0
                            return
                        }

                        if filtered != numString {
                            numString = filtered
                        }

                        num = Int(filtered) ?? 0
                    }
                    .onChange(of: num) {
                        if numString != String(num) {
                            numString = String(num)
                        }
                    }
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}
