//
//  ThirdPartyRandomItemResponse.swift
//  Hako
//
//  Created by Gao Tianrun on 26/6/25.
//

import Foundation

struct ThirdPartyRandomItemResponse: Codable {
    let data: ThirdPartyRandomItem
}

struct ThirdPartyRandomItem: Codable {
    let malId: Int
}
