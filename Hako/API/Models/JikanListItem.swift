//
//  JikanListItem.swift
//  Hako
//
//  Created by Gao Tianrun on 11/5/24.
//

import Foundation

struct JikanListItem: Codable, Identifiable {
    var id: Int { malId }
    let malId: Int
    let title: String?
    let titleEnglish: String?
    let name: String?
    let images: Images?
    let type: TypeEnum?
    let url: String?
}
