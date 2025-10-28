//
//  PersonListItem.swift
//  Hako
//
//  Created by Gao Tianrun on 24/10/25.
//

import SwiftUI

struct PersonListItem: View {
    @EnvironmentObject private var settings: SettingsManager
    private let person: JikanListItem
    private let subtitle: String?
    
    init(person: JikanListItem) {
        self.person = person
        self.subtitle = nil
    }
    
    init(person: Staff) {
        self.person = person.person
        self.subtitle = person.positions.joined(separator: ", ")
    }
    
    var body: some View {
        NavigationLink {
            PersonDetailsView(id: person.id, name: person.name)
        } label: {
            HStack {
                ImageFrame(id: "person\(person.id)", imageUrl: person.images?.jpg?.imageUrl, imageSize: .small)
                VStack(alignment: .leading, spacing: 5) {
                    Text(person.name ?? "")
                        .lineLimit(settings.getLineLimit())
                        .bold()
                        .font(.system(size: 16))
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .foregroundStyle(Color(.systemGray))
                            .font(.system(size: 13))
                    }
                }
                .padding(5)
            }
            .contextMenu {
                ShareLink(item: URL(string: "https://myanimelist.net/people/\(person.id)")!) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
        }
        .padding(5)
    }
}

