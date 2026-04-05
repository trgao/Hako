//
//  Person.swift
//  Hako
//
//  Created by Gao Tianrun on 21/5/24.
//

import Foundation

struct Person: Codable, Identifiable {
    var id: Int { malId }
    let malId: Int
    let name: String
    let birthday: Date?
    let about: String?
    let images: Images?
    let favorites: Int?
    let anime: [AnimePosition]?
    let manga: [MangaPosition]?
    let voices: [AnimeVoice]?
    
    init(id: Int, name: String?, imageUrl: String?) {
        self.malId = id
        self.name = name ?? ""
        self.birthday = nil
        self.about = nil
        self.images = Images(imageUrl: imageUrl)
        self.favorites = nil
        self.anime = nil
        self.manga = nil
        self.voices = nil
    }
    
    // Used to check if the model has been loaded from API or just used information from previous page, might need better way of checking this
    func isEmpty() -> Bool {
        return birthday == nil && about == nil && favorites == nil && anime == nil && manga == nil && voices == nil
    }
}
