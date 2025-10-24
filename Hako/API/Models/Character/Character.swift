//
//  Character.swift
//  Hako
//
//  Created by Gao Tianrun on 2/5/24.
//

import Foundation

struct Character: Codable, Identifiable {
    var id: Int { malId }
    let malId: Int
    let name: String?
    let nameKanji: String?
    let about: String?
    let images: Images?
    let favorites: Int?
    let anime: [Animeography]?
    let manga: [Mangaography]?
    let voices: [Voice]?
    
    init(id: Int, name: String?) {
        self.malId = id
        self.name = name
        self.nameKanji = nil
        self.about = nil
        self.images = nil
        self.favorites = nil
        self.anime = nil
        self.manga = nil
        self.voices = nil
    }
}
