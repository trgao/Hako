//
//  NumberSelector.swift
//  Hako
//
//  Created by Gao Tianrun on 7/10/24.
//

import SwiftUI
import Combine

struct NumberSelector: View {
    @Binding var num: Int
    @State var numString: String
    private var title: String
    private var max: Int?
    
    init(num: Binding<Int>, title: String, max: Int?) {
        self._num = num
        self.title = title
        self.max = max
        self.numString = String(num.wrappedValue)
    }

    var body: some View {
        if let max = max, max > 0 && max < 500 {
            PickerRow(title: title, selection: $num, labels: (0...max).map(String.init))
        } else {
            HStack {
                Text(title)
                TextField("", text: $numString)
                    .keyboardType(.numberPad)
                    .onReceive(Just(numString)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.numString = filtered
                        }
                        self.num = Int(numString) ?? 0
                    }
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}
