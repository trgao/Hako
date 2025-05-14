//
//  ThemeSongs.swift
//  MALC
//
//  Created by Gao Tianrun on 13/5/25.
//

import SwiftUI

struct ThemeSongs: View {
    private let openingThemes: [Theme]?
    private let endingThemes: [Theme]?
    
    init(openingThemes: [Theme]?, endingThemes: [Theme]?) {
        self.openingThemes = openingThemes
        self.endingThemes = endingThemes
    }
    
    var body: some View {
        if let openingThemes = openingThemes {
            Section {
                ForEach(openingThemes) { theme in
                    Text(theme.text ?? "")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } header: {
                Text("Openings")
                    .textCase(nil)
                    .foregroundColor(Color.primary)
                    .font(.system(size: 17))
                    .bold()
            }
        }
        if let endingThemes = endingThemes {
            Section {
                ForEach(endingThemes) { theme in
                    Text(theme.text ?? "")
                }
            } header: {
                Text("Endings")
                    .textCase(nil)
                    .foregroundColor(Color.primary)
                    .font(.system(size: 17))
                    .bold()
            }
        }
    }
}
