//
//  Staffs.swift
//  MALC
//
//  Created by Gao Tianrun on 14/5/24.
//

import SwiftUI

struct Staffs: View {
    @StateObject var controller: StaffsController
    @State private var isRefresh = false
    
    init(id: Int) {
        self._controller = StateObject(wrappedValue: StaffsController(id: id))
    }
    
    var body: some View {
        if !controller.isLoading && !controller.staffs.isEmpty {
            Section {} header: {
                VStack {
                    NavigationLink {
                        StaffsListView(staffs: controller.staffs)
                    } label: {
                        HStack {
                            Text("Staffs")
                                .bold()
                            Image(systemName: "chevron.right")
                        }
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
                                            .padding([.trailing], 10)
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
        }
    }
}
