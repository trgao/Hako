//
//  Video.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import Foundation

struct Video: Codable, Identifiable, Equatable {
    let id: Int
    let title: String?
    let url: String?
}
