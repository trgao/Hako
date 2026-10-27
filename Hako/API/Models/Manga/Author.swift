//
//  Author.swift
//  Hako
//
//  Created by Gao Tianrun on 13/5/25.
//

import Foundation

struct Author: Codable, Identifiable, Hashable {
    var id: Int { node.id }
    let node: AuthorNode
    let role: String?
    var imageUrl: String?
}

struct AuthorNode: Codable, Identifiable, Hashable {
    let id: Int
    let firstName: String?
    let lastName: String?
}
