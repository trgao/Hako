//
//  Favourites.swift
//  Hako
//
//  Created by Gao Tianrun on 16/6/25.
//

import SwiftUI

struct Favourites: View {
    private var favorites: Int?
    
    init(favorites: Int?) {
        self.favorites = favorites
    }
    
    var body: some View {
        Section {
            if let favorites = favorites {
                Label("\(favorites) favorites", systemImage: "star.fill")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        } header: {
            Rectangle()
                .frame(height: 0)
        }
        .listRowInsets(.init())
    }
}

