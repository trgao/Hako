//
//  Chapter.swift
//  Hako
//
//  Created by Gao Tianrun on 15/10/26.
//

import Foundation

struct Chapter: Codable, Identifiable {
    var id: Int { malId }
    let malId: Int
    let title: String
    let url: String?
    let comments: Int?
}
