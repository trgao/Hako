//
//  PersonListItem.swift
//  Hako
//
//  Created by Gao Tianrun on 24/10/25.
//

import SwiftUI

struct PersonListItem: View {
    @EnvironmentObject private var settings: SettingsManager
    private let person: ThirdPartyListItem
    private let subtitle: String?
    private let item: Person

    init(person: ThirdPartyListItem) {
        self.person = person
        self.subtitle = person.birthday?.toString()
        self.item = Person(id: person.id, name: person.name, imageUrl: person.images?.jpg?.imageUrl)
    }

    init(person: Staff) {
        self.person = person.person
        self.subtitle = person.positions.joined(separator: ", ")
        self.item = Person(id: person.person.id, name: person.person.name, imageUrl: person.person.images?.jpg?.imageUrl)
    }

    var body: some View {
        TrackedNavigationLink(value: item) {
            HStack {
                ImageFrame(id: "person\(person.id)", imageUrl: person.images?.jpg?.imageUrl, imageSize: Constants.listImageSize)
                VStack(alignment: .leading, spacing: 5) {
                    Text(person.name ?? "")
                        .lineLimit(settings.getLineLimit())
                        .bold()
                    if let subtitle {
                        Text(subtitle)
                            .foregroundStyle(Color(.systemGray))
                            .font(.footnote)
                    }
                }
                .padding(5)
                .foregroundStyle(Color.primary)
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
