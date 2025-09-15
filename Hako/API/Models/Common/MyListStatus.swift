//
//  MyListStatus.swift
//  Hako
//
//  Created by Gao Tianrun on 14/9/25.
//

import Foundation

struct MyListStatus: Codable, Equatable {
    var status: StatusEnum?
    var score = 0
    var numEpisodesWatched = 0
    var numChaptersRead = 0
    var numVolumesRead = 0
    var startDate: Date?
    var finishDate: Date?
    var updatedAt: Date?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MyListStatus.CodingKeys.self)
        self.status = try container.decodeIfPresent(StatusEnum.self, forKey: .status)
        self.score = try container.decode(Int.self, forKey: .score)
        self.numEpisodesWatched = try container.decodeIfPresent(Int.self, forKey: .numEpisodesWatched) ?? 0
        self.numChaptersRead = try container.decodeIfPresent(Int.self, forKey: .numChaptersRead) ?? 0
        self.numVolumesRead = try container.decodeIfPresent(Int.self, forKey: .numVolumesRead) ?? 0
        self.startDate = try container.decodeIfPresent(Date.self, forKey: .startDate)
        self.finishDate = try container.decodeIfPresent(Date.self, forKey: .finishDate)
        self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
    }
    
    init(status: StatusEnum) {
        self.status = status
        self.startDate = nil
        self.finishDate = nil
        self.updatedAt = nil
    }
}
