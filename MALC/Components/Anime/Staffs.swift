//
//  Staffs.swift
//  MALC
//
//  Created by Gao Tianrun on 14/5/24.
//

import SwiftUI

struct Staffs: View {
    @StateObject var controller: AnimeDetailsViewController
    @State private var isRefresh = false
    
    init(controller: AnimeDetailsViewController) {
        self._controller = StateObject(wrappedValue: controller)
    }
    
    var body: some View {
        if !controller.staffs.isEmpty {
            Section {} header: {
                VStack {
                    NavigationLink {
                        StaffsListView(staffs: controller.staffs)
                    } label: {
                        HStack {
                            Text("Staffs")
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color(.systemGray2))
                        }
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 30)
                        .font(.system(size: 17))
                    }
                    .buttonStyle(.plain)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            Rectangle()
                                .frame(width: 5)
                                .foregroundColor(.clear)
                            ForEach(controller.staffs.prefix(10)) { staff in
                                ZoomTransition {
                                    PersonDetailsView(id: staff.id)
                                } label: {
                                    VStack {
                                        ImageFrame(id: "person\(staff.id)", imageUrl: staff.person.images?.jpg.imageUrl, imageSize: .medium)
                                        Text(staff.person.name ?? "")
                                            .font(.system(size: 14))
                                    }
                                    .frame(width: 120)
                                }
                            }
                            Rectangle()
                                .frame(width: 5)
                                .foregroundColor(.clear)
                        }
                    }
                }
                .textCase(nil)
                .padding(.horizontal, -15)
                .foregroundColor(Color.primary)
                .listRowInsets(.init())
            }
            .listRowInsets(.init())
        }
    }
}
