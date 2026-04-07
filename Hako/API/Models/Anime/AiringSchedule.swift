//
//  AiringSchedule.swift
//  Hako
//
//  Created by Gao Tianrun on 3/4/26.
//

import Foundation

struct AiringSchedule: Codable, Identifiable {
    struct Media: Codable, Identifiable {
        struct Title: Codable {
            let romaji: String?
            let native: String?
            let english: String?
        }
        
        struct CoverImage: Codable {
            let large: String?
        }
        
        let id: Int
        let idMal: Int?
        let title: Title
        let coverImage: CoverImage?
        let season: String?
        let seasonYear: Int?
        let duration: Int?
    }
    
    var id: String { "\(media.id), episode\(episode)" }
    let episode: Int
    let airingAt: Int
    let media: Media
}
