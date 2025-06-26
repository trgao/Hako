//
//  JikanRandomItemResponse.swift
//  Hako
//
//  Created by Gao Tianrun on 26/6/25.
//

import Foundation

struct JikanRandomItemResponse: Codable {
    let data: JikanRandomItem
}

struct JikanRandomItem: Codable {
    let malId: Int
}
