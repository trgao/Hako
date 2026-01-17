//
//  AnimeMangaToggle.swift
//  Hako
//
//  Created by Gao Tianrun on 6/5/24.
//

import SwiftUI

struct AnimeMangaToggle: View {
    @EnvironmentObject private var settings: SettingsManager
    @State private var offset: CGFloat = -17
    @Binding var type: TypeEnum
    private let isLoading: Bool
    
    init(type: Binding<TypeEnum>, isLoading: Bool) {
        self._type = type
        self.isLoading = isLoading
    }
    
    var body: some View {
        ZStack {
            if #available (iOS 26.0, *) {
                Capsule()
                    .stroke(Color(.systemGray6), lineWidth: 1)
                    .frame(width: 70, height: 35)
                    .foregroundStyle(.clear)
            } else {
                Capsule()
                    .frame(width: 70, height: 35)
                    .foregroundStyle(Color(.systemGray5))
            }
            ZStack{
                Circle()
                    .frame(width: 33, height: 33)
                    .foregroundColor(.white)
            }
            .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
            .offset(x: offset)
            .padding(24)
            HStack {
                Image(systemName: "tv.fill")
                    .resizable()
                    .frame(width: 18, height: 15)
                    .foregroundStyle(type == .anime && !isLoading ? settings.getAccentColor() : Color(.systemGray))
                    .drawingGroup()
                    .padding(3)
                    .offset(x: -1)
                Image(systemName: "book.fill")
                    .resizable()
                    .frame(width: 18, height: 15)
                    .foregroundStyle(type == .manga && !isLoading ? settings.getAccentColor() : Color(.systemGray))
                    .drawingGroup()
                    .padding(3)
                    .offset(x: 1)
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: type)
        .onTapGesture {
            if type == .anime {
                type = .manga
            } else if type == .manga {
                type = .anime
            }
        }
        .task(id: type) {
            withAnimation {
                if type == .anime {
                    offset = -17
                } else if type == .manga {
                    offset = 17
                }
            }
        }
        .disabled(isLoading)
    }
}
