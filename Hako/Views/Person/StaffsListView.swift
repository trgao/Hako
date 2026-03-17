//
//  StaffsListView.swift
//  Hako
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct StaffsListView: View {
    private let staffs: [Staff]
    
    init(staffs: [Staff]) {
        self.staffs = staffs
    }
    
    var body: some View {
        List {
            ForEach(staffs) { staff in
                PersonListItem(person: staff)
            }
        }
        .navigationTitle("Staffs")
    }
}
