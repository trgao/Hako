//
//  JikanAPIStatusResponse.swift
//  Hako
//
//  Created by Gao Tianrun on 15/4/26.
//

import Foundation

struct JikanAPIStatusResponse: Codable {
    let status: Int?
    let myanimelistHeartbeat: MALHeartbeat?
}

struct MALHeartbeat: Codable {
    let status: String?
    let down: Bool?
}
