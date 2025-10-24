//
//  PersonGridItem.swift
//  Hako
//
//  Created by Gao Tianrun on 24/10/24.
//

import SwiftUI

struct PersonGridItem: View {
    @EnvironmentObject private var settings: SettingsManager
    private let id: Int
    private let name: String?
    private let imageUrl: String?
    
    init(id: Int, name: String?, imageUrl: String?) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
    }
    
    var body: some View {
        ZoomTransition {
            PersonDetailsView(id: id, name: name)
        } label: {
            VStack {
                ImageFrame(id: "person\(id)", imageUrl: imageUrl, imageSize: .medium)
                Text(name ?? "")
                    .lineLimit(settings.getLineLimit())
                    .font(.system(size: 14))
            }
            .frame(width: 110)
        }
    }
}
