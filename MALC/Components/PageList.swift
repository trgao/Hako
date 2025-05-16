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
            Section {} header: {
                VStack(alignment: .center) {
                    header()
                }
                .listRowInsets(.init())
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .textCase(nil)
            .padding(.horizontal, -20)
            .foregroundColor(Color.primary)
            .listRowInsets(.init())
            content()
        }
        .listStyle(.insetGrouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
