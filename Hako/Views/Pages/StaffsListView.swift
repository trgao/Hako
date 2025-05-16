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
                NavigationLink {
                    PersonDetailsView(id: staff.id)
                } label: {
                    HStack {
                        ImageFrame(id: "person\(staff.id)", imageUrl: staff.person.images?.jpg.imageUrl, imageSize: .small)
                            .padding([.trailing], 10)
                        VStack(alignment: .leading) {
                            Text(staff.person.name ?? "")
                            Text(staff.positions.joined(separator: ", "))
                                .foregroundStyle(Color(.systemGray))
                                .font(.system(size: 13))
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Staffs")
    }
}
