//
//  PlaceholderAiringSchedule.swift
//  Hako
//
//  Created by Gao Tianrun on 12/4/26.
//

import SwiftUI

struct PlaceholderAiringSchedule: View {
    @Environment(\.screenRatio) private var screenRatio
    @EnvironmentObject private var settings: SettingsManager
    private var width: CGFloat {
        Constants.listImageSize == .medium ? 100 * screenRatio : 75 * screenRatio
    }
    private var height: CGFloat {
        Constants.listImageSize == .medium ? 142 * screenRatio : 106 * screenRatio
    }
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.gray)
                .opacity(0.7)
                .frame(width: width, height: height)
            VStack(alignment: .leading) {
                Text("placeholderplaceholderplaceholderplaceholder")
                    .lineLimit(settings.getLineLimit())
                    .bold()
                Text("placeholderplaceholder")
                    .opacity(0.7)
                    .font(.footnote)
                    .padding(.top, 2)
                Label("Episode 0 aired at placeholder", systemImage: "alarm.fill")
                    .foregroundStyle(settings.getAccentColor())
                    .bold()
                    .font(.footnote)
                    .padding(.top, 2)
            }
            .padding(.horizontal, 5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .skeleton()
    }
}
