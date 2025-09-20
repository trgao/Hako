//
//  ScrollViewListItem.swift
//  Hako
//
//  Created by Gao Tianrun on 20/9/25.
//

import SwiftUI

struct ScrollViewListItem<Photo: View, Destination: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false
    private let title: String?
    private let subtitle: String?
    private let photo: () -> Photo
    private let destination: () -> Destination
    init(title: String?, subtitle: String?, @ViewBuilder photo: @escaping () -> Photo, @ViewBuilder destination: @escaping () -> Destination) {
        self.title = title
        self.subtitle = subtitle
        self.photo = photo
        self.destination = destination
    }
    
    var body: some View {
        HStack(spacing: 10) {
            photo()
                .padding(.trailing, 10)
            HStack {
                VStack(alignment: .leading) {
                    Text(title ?? "")
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    Text(subtitle ?? "")
                        .foregroundStyle(Color(.systemGray))
                        .font(.system(size: 13))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .bold()
                    .font(.system(size: 12))
                    .foregroundStyle(Color(.systemGray2))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isPressed = true
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(isPressed ? Color(.systemGray3) : (colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground)))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .navigationDestination(isPresented: $isPressed, destination: destination)
    }
}
