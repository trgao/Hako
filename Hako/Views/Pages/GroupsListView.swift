//
//  GroupsListView.swift
//  Hako
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct GroupsListView: View {
    private let title: String
    private let items: [MALItem]
    private let group: String
    private let type: TypeEnum
    
    init(title: String, items: [MALItem], group: String, type: TypeEnum) {
        self.title = title
        self.items = items
        self.group = group
        self.type = type
    }
    
    var body: some View {
        List {
            ForEach(items) { item in
                NavigationLink(item.name) {
                    GroupDetailsView(title: item.name, group: group, id: item.id, type: type)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle(title)
    }
}
