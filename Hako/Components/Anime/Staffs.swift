//
//  Staffs.swift
//  Hako
//
//  Created by Gao Tianrun on 14/5/24.
//

import SwiftUI

struct Staffs: View {
    private let staffs: [Staff]
    private let load: () async -> Void
    
    init(staffs: [Staff], load: @escaping () async -> Void) {
        self.staffs = staffs
        self.load = load
    }
    
    var body: some View {
        VStack {
            if !staffs.isEmpty {
                ScrollViewCarousel(title: "Staffs", count: staffs.count, spacing: 15) {
                    ForEach(staffs.prefix(10)) { staff in
                        PersonGridItem(id: staff.id, name: staff.person.name, imageUrl: staff.person.images?.jpg?.imageUrl)
                    }
                } destination: {
                    StaffsListView(staffs: staffs)
                }
            }
        }
        .task {
            await load()
        }
    }
}
