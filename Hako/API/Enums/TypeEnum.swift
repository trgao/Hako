//
//  TypeEnum.swift
//  Hako
//
//  Created by Gao Tianrun on 13/5/24.
//

import Foundation

enum TypeEnum: String, Codable {
    case anime, manga, none
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let type = try container.decode(String.self)
        self = .init(rawValue: type) ?? .none
    }
}
