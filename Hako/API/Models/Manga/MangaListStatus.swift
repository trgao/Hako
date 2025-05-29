//
//  MangaListStatus.swift
//  Hako
//
//  Created by Gao Tianrun on 13/5/24.
//

import Foundation

struct MangaListStatus: Codable, Equatable {
    var status: StatusEnum?
    var score: Int
    var numVolumesRead: Int
    var numChaptersRead: Int
    var startDate: Date?
    var finishDate: Date?
    let updatedAt: Date?
}
