//
//  StaffsListView.swift
//  Hako
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct StaffsListView: View {
    @State private var query = ""
    private let staffs: [Staff]
    
    init(staffs: [Staff]) {
        self.staffs = staffs
    }
    
    var body: some View {
        List {
            let staffsFiltered = staffs.filter { item in
                guard let name = item.person.name else {
                    return false
                }
                if query == "" {
                    return true
                }
                let name1 = name.filter { $0 != "," }.lowercased()
                let name2 = name.split(separator: ",").reversed().joined(separator: " ").lowercased()
                let queryLowercased = query.lowercased()
                
                return name1.contains(queryLowercased) || name2.contains(queryLowercased)
            }
            ForEach(staffsFiltered) { staff in
                PersonListItem(person: staff)
            }
        }
        .navigationTitle("Staffs")
        .searchable(text: $query, prompt: "Search staff")
    }
}
