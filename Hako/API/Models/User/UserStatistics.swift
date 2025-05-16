//
//  UserStatistics.swift
//  Hako
//
//  Created by Gao Tianrun on 22/11/24.
//

import Foundation

struct UserStatistics: Codable {
    let anime: UserAnimeStatistics
    let manga: UserMangaStatistics
}

struct UserAnimeStatistics: Codable {
    let daysWatched: Float
    let meanScore: Float
    let watching: Int
    let completed: Int
    let onHold: Int
    let dropped: Int
    let planToWatch: Int
    let totalEntries: Int
    let episodesWatched: Int
}

struct UserMangaStatistics: Codable {
    let daysRead: Float
    let meanScore: Float
    let reading: Int
    let completed: Int
    let onHold: Int
    let dropped: Int
    let planToRead: Int
    let totalEntries: Int
    let chaptersRead: Int
    let volumesRead: Int
}
