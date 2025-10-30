//
//  Manga.swift
//  Hako
//
//  Created by Gao Tianrun on 6/5/24.
//

import Foundation

struct Manga: Codable, Identifiable {
    let id: Int
    let title: String
    let mainPicture: MainPicture?
    let pictures: [Picture]?
    let alternativeTitles: AlternativeTitles?
    let startDate: Date?
    let endDate: Date?
    let synopsis: String?
    let mean: Double?
    let rank: Int?
    let popularity: Int?
    let mediaType: String?
    let status: String?
    let genres: [MALItem]?
    var myListStatus: MyListStatus?
    let numVolumes: Int?
    let numChapters: Int?
    let authors: [Author]?
    let serialization: [Magazine]?
    let recommendations: [MALListManga]?
    let numListUsers: Int?
    
    init(id: Int, title: String, enTitle: String?) {
        self.id = id
        self.title = title
        self.alternativeTitles = AlternativeTitles(ja: nil, en: enTitle)
        self.mainPicture = nil
        self.pictures = nil
        self.startDate = nil
        self.endDate = nil
        self.synopsis = nil
        self.mean = nil
        self.rank = nil
        self.popularity = nil
        self.mediaType = nil
        self.status = nil
        self.genres = nil
        self.myListStatus = nil
        self.numVolumes = nil
        self.numChapters = nil
        self.authors = nil
        self.serialization = nil
        self.recommendations = nil
        self.numListUsers = nil
    }
    
    init(item: JikanListItem) {
        self.id = item.id
        self.title = item.title ?? ""
        self.alternativeTitles = AlternativeTitles(ja: item.titleJapanese, en: item.titleEnglish)
        self.mainPicture = MainPicture(medium: item.images?.jpg?.imageUrl, large: item.images?.jpg?.largeImageUrl)
        self.pictures = nil
        self.startDate = nil
        self.endDate = nil
        self.synopsis = item.synopsis
        self.mean = item.score
        self.rank = item.rank
        self.popularity = item.popularity
        self.mediaType = item.type
        self.status = item.status
        self.genres = nil
        self.myListStatus = nil
        self.numVolumes = item.volumes
        self.numChapters = item.chapters
        self.authors = nil
        self.serialization = nil
        self.recommendations = nil
        self.numListUsers = item.members
    }
}
