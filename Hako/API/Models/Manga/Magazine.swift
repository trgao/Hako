//
//  Magazine.swift
//  Hako
//
//  Created by Gao Tianrun on 13/5/25.
//

import Foundation

struct Magazine: Codable, Identifiable, Hashable {
    var id: Int { node.id }
    let node: MALItem
}
