//
//  PageList.swift
//  Hako
//
//  Created by Gao Tianrun on 13/5/25.
//

import SwiftUI

struct PageList<Content: View, Photo: View, Title: View, Subtitle: View>: View {
    let content: () -> Content
    let photo: () -> Photo
    let title: () -> Title
    let subtitle: () -> Subtitle

    init(@ViewBuilder content: @escaping () -> Content, @ViewBuilder photo: @escaping () -> Photo = { EmptyView() }, @ViewBuilder title: @escaping () -> Title = { EmptyView() }, @ViewBuilder subtitle: @escaping () -> Subtitle = { EmptyView() }) {
        self.content = content
        self.photo = photo
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        List {
            Section {
                photo()
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .frame(maxWidth: .infinity, alignment: .center)
            } header: {
                Rectangle()
                    .frame(height: 10)
                    .foregroundStyle(.clear)
            } footer: {
                Rectangle()
                    .frame(height: 0)
            }
            .listRowInsets(.init())
            Section {
                title()
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .frame(maxWidth: .infinity, alignment: .center)
            } header: {
                Rectangle()
                    .frame(height: 5)
                    .foregroundStyle(.clear)
            } footer: {
                Rectangle()
                    .frame(height: 0)
            }
            .listRowInsets(.init())
            Section {
                subtitle()
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
