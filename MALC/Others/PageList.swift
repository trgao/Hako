//
//  PageList.swift
//  MALC
//
//  Created by Gao Tianrun on 13/5/25.
//

import SwiftUI

struct PageList<Header: View, Content: View>: View {
    let content: () -> Header
    let header: () -> Content

    init(@ViewBuilder content: @escaping () -> Header, @ViewBuilder header: @escaping () -> Content) {
        self.content = content
        self.header = header
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .center) {
                    header()
                }
                .frame(maxWidth: .infinity, alignment: .center)
            } header: {
                Spacer(minLength: 0).listRowInsets(EdgeInsets())
            }
            .listRowBackground(Color.clear)
            content()
        }
        .listStyle(.insetGrouped)
        .environment(\.defaultMinListHeaderHeight, 0)
    }
}
