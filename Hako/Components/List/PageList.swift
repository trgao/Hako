//
//  PageList.swift
//  Hako
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
                header()
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .frame(maxWidth: .infinity, alignment: .center)
            } header: {
                Rectangle()
                    .frame(height: 0)
            } footer: {
                Rectangle()
                    .frame(height: 0)
            }
            .listRowInsets(.init())
            content()
        }
        .listStyle(.insetGrouped)
        .environment(\.defaultMinListHeaderHeight, 0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
