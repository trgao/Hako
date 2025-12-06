//
//  ListItem.swift
//  Hako
//
//  Created by Gao Tianrun on 6/12/25.
//

import Foundation

struct ListItem: Codable, Identifiable {
    let id: Int
    let title: String
    let enTitle: String?
    let imageUrl: String?
    let type: TypeEnum
}
