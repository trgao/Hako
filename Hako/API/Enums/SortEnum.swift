//
//  SortEnum.swift
//  Hako
//
//  Created by Gao Tianrun on 8/1/26.
//

import Foundation

enum SortEnum: String {
    case listScore, listUpdatedAt, animeTitle, animeStartDate, mangaTitle, mangaStartDate
    
    func toParameter() -> String {
        switch self {
        case .listScore: return "list_score"
        case .listUpdatedAt: return "list_updated_at"
        case .animeTitle: return "anime_title"
        case .animeStartDate: return "anime_start_date"
        case .mangaTitle: return "manga_title"
        case .mangaStartDate: return "manga_start_date"
        }
    }
    
    func toString() -> String {
        switch self {
        case .listScore: return "By score"
        case .listUpdatedAt: return "By last update"
        case .animeTitle, .mangaTitle: return "By title"
        case .animeStartDate, .mangaStartDate: return "By start date"
        }
    }
}
