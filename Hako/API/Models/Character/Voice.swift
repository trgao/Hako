//
//  Voice.swift
//  Hako
//
//  Created by Gao Tianrun on 2/5/24.
//

import Foundation

struct Voice: Codable, Identifiable {
    var id: Int { person.id }
    let person: JikanListItem
    let language: String?
}
