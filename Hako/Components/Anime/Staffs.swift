//
//  Staffs.swift
//  Hako
//
//  Created by Gao Tianrun on 14/5/24.
//

import SwiftUI

struct Staffs: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject var controller: AnimeDetailsViewController
    @State private var isRefresh = false
    
    init(controller: AnimeDetailsViewController) {
        self._controller = StateObject(wrappedValue: controller)
    }
    
    var body: some View {
        VStack {
            if !controller.staffs.isEmpty {
                ScrollViewCarousel(title: "Staffs", items: controller.staffs) {
                    ScrollView(.horizontal) {
                        HStack(alignment: .top, spacing: 15) {
                            ForEach(controller.staffs.prefix(10)) { staff in
                                PersonGridItem(id: staff.id, name: staff.person.name, imageUrl: staff.person.images?.jpg?.imageUrl)
                            }
                        }
                        .padding(.horizontal, 17)
                        .padding(.top, 17)
                    }
                    .scrollIndicators(.never)
                    .padding(.top, -15)
                } destination: {
                    StaffsListView(staffs: controller.staffs)
                }
            }
        }
        .task {
            await controller.loadStaffs()
        }
    }
}
