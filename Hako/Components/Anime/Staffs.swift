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
        if !controller.staffs.isEmpty {
            ScrollViewCarousel(title: "Staffs", items: controller.staffs) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top) {
                        ForEach(controller.staffs.prefix(10)) { staff in
                            ZoomTransition {
                                PersonDetailsView(id: staff.id)
                            } label: {
                                VStack {
                                    ImageFrame(id: "person\(staff.id)", imageUrl: staff.person.images?.jpg?.imageUrl, imageSize: .medium)
                                    Text(staff.person.name ?? "")
                                        .lineLimit(settings.getLineLimit())
                                        .font(.system(size: 14))
                                }
                                .frame(width: 120)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            } destination: {
                StaffsListView(staffs: controller.staffs)
            }
        }
    }
}
