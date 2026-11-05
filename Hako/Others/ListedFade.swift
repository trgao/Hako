//
//  ListedFade.swift
//  Hako
//
//  Created by Gao Tianrun on 1/11/26.
//

import SwiftUI

// Fades an item and adds a small status badge, similar to Letterboxd's "fade watched films"
struct ListedFade: ViewModifier {
    let show: Bool
    let id: Int
    let type: TypeEnum
    let networker = NetworkManager.shared

    private var status: StatusEnum? {
        if type == .anime {
            return networker.getAnimeListStatus(id).value?.status
        } else {
            return networker.getMangaListStatus(id).value?.status
        }
    }

    private var showFade: Bool {
        show && status != nil
    }

    func body(content: Content) -> some View {
        content
            .opacity(showFade ? 0.35 : 1)
            // Overlay comes after opacity so the badge stays fully opaque
            .overlay(alignment: .topTrailing) {
                if let status, show {
                    Label(status.toString(), systemImage: status.toIcon())
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(5)
                        .background(.black.opacity(0.6), in: Capsule())
                        .padding(.top, 7)
                        .padding(.trailing, 12)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: showFade)
    }
}

extension View {
    func listedFade(show: Bool, id: Int, type: TypeEnum) -> some View {
        modifier(ListedFade(show: show, id: id, type: type))
    }
}
