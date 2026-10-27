//
//  Theme.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import Foundation

struct Theme: Codable, Identifiable, Hashable {
    let id: Int
    let animeId: Int?
    let text: String?
}
