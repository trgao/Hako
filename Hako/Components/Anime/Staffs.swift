//
//  Staffs.swift
//  Hako
//
//  Created by Gao Tianrun on 14/5/24.
//

import SwiftUI

struct Staffs: View {
    @State private var staffsPreview: [Staff] = []
    private let staffs: [Staff]?
    private let loadingState: LoadingEnum
    private let load: () async -> Void
    
    init(staffs: [Staff]?, loadingState: LoadingEnum, load: @escaping () async -> Void) {
        self.staffs = staffs
        self.loadingState = loadingState
        self.load = load
    }
    
    var body: some View {
        ScrollViewCarousel(title: "Staffs", count: staffs?.count, loadingState: loadingState, refresh: load, placeholder: SmallPlaceholderGridItem.init) {
            ForEach(staffsPreview) { staff in
                PersonGridItem(id: staff.id, name: staff.person.name, imageUrl: staff.person.images?.jpg?.imageUrl)
            }
        } destination: {
            StaffsListView(staffs: staffs ?? [])
        }
        .task {
            await load()
        }
        .onChange(of: staffs?.count) {
            staffsPreview = Array(staffs?.prefix(10) ?? [])
        }
    }
}
