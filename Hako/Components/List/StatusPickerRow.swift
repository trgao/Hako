//
//  StatusPickerRow.swift
//  Hako
//
//  Created by Gao Tianrun on 7/1/26.
//

import SwiftUI

struct StatusPickerRow: View {
    @Binding var selection: StatusEnum?
    private let type: TypeEnum
    
    init(selection: Binding<StatusEnum?>, type: TypeEnum) {
        self._selection = selection
        self.type = type
    }
    
    var body: some View {
        Picker("Status", selection: $selection) {
            ForEach((type == .anime ? Constants.animeStatuses : Constants.mangaStatuses).filter { $0 != .none }, id: \.self) { status in
                Text(status.toString()).tag(status)
            }
        }
    }
}
