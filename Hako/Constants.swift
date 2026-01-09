//
//  Constants.swift
//  Hako
//
//  Created by Gao Tianrun on 30/11/25.
//

import SwiftUI

struct Constants {
    static let colorSchemes: [ColorScheme?] = [nil, .light, .dark]
    static let accentColors: [Color] = [.blue, .teal, .orange, .pink, .indigo, .purple, .green, .brown]
    static let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 150), alignment: .top),
    ]
    
    static let currentYear = Calendar(identifier: .gregorian).dateComponents([.year], from: .now).year ?? 2001
    static let seasons: [SeasonEnum] = [.winter, .spring, .summer, .fall]
    
    // Since genres should not change much, I have decided to hard code this instead of relying on Jikan API genres endpoint
    static let animeGenres = [
        1: "Action",
        2: "Adventure",
        5: "Avant Garde",
        46: "Award Winning",
        28: "Boys Love",
        4: "Comedy",
        8: "Drama",
        10: "Fantasy",
        26: "Girls Love",
        47: "Gourmet",
        14: "Horror",
        7: "Mystery",
        22: "Romance",
        24: "Sci-Fi",
        36: "Slice Of Life",
        30: "Sports",
        37: "Supernatural",
        41: "Suspense",
        9: "Ecchi",
        49: "Erotica",
    ]
    static let animeGenreKeys = [1, 2, 5, 46, 28, 4, 8, 10, 26, 47, 14, 7, 22, 24, 36, 30, 37, 41, 9, 49]
    static let animeThemes = [
        50: "Adult Cast",
        51: "Anthropomorphic",
        52: "CGDCT",
        53: "Childcare",
        54: "Combat Sports",
        81: "Crossdressing",
        55: "Delinquents",
        39: "Detective",
        56: "Educational",
        57: "Gag Humour",
        58: "Gore",
        35: "Harem",
        59: "High Stakes Game",
        13: "Historical",
        60: "Idols (Female)",
        61: "Idols (Male)",
        62: "Isekai",
        63: "Iyashikei",
        64: "Love Polygon",
        74: "Love Status Quo",
        65: "Magical Sex Shift",
        66: "Mahou Shoujo",
        17: "Martial Arts",
        18: "Mecha",
        67: "Medical",
        38: "Military",
        19: "Music",
        6: "Mythology",
        68: "Organised Crime",
        69: "Otaku Culture",
        20: "Parody",
        70: "Performing Arts",
        71: "Pets",
        40: "Psychological",
        3: "Racing",
        72: "Reincarnation",
        73: "Reverse Harem",
        21: "Samurai",
        23: "School",
        75: "Showbiz",
        29: "Space",
        11: "Strategy Game",
        31: "Super Power",
        76: "Survival",
        77: "Team Sports",
        78: "Time Travel",
        82: "Urban Fantasy",
        32: "Vampire",
        79: "Video Game",
        83: "Villainess",
        80: "Visual Arts",
        48: "Workplace",
    ]
    static let animeThemeKeys = [50, 51, 52, 53, 54, 81, 55, 39, 56, 57, 58, 35, 59, 13, 60, 61, 62, 63, 64, 74, 65, 66, 17, 18, 67, 38, 19, 6, 68, 69, 20, 70, 71, 40, 3, 72, 73, 21, 23, 75, 29, 11, 31, 76, 77, 78, 82, 32, 79, 83, 80, 48]
    static let animeDemographics = [
        43: "Josei",
        15: "Kids",
        42: "Seinen",
        25: "Shoujo",
        27: "Shounen",
    ]
    static let animeDemographicKeys = [43, 15, 42, 25, 27]
    
    static let mangaGenres = [
        1: "Action",
        2: "Adventure",
        5: "Avant Garde",
        46: "Award Winning",
        28: "Boys Love",
        4: "Comedy",
        8: "Drama",
        10: "Fantasy",
        26: "Girls Love",
        47: "Gourmet",
        14: "Horror",
        7: "Mystery",
        22: "Romance",
        24: "Sci-Fi",
        36: "Slice Of Life",
        30: "Sports",
        37: "Supernatural",
        45: "Suspense",
        9: "Ecchi",
        49: "Erotica",
    ]
    static let mangaGenreKeys = [1, 2, 5, 46, 28, 4, 8, 10, 26, 47, 14, 7, 22, 24, 36, 30, 37, 45, 9, 49]
    static let mangaThemes = [
        50: "Adult Cast",
        51: "Anthropomorphic",
        52: "CGDCT",
        53: "Childcare",
        54: "Combat Sports",
        44: "Crossdressing",
        55: "Delinquents",
        39: "Detective",
        56: "Educational",
        57: "Gag Humour",
        58: "Gore",
        35: "Harem",
        59: "High Stakes Game",
        13: "Historical",
        60: "Idols (Female)",
        61: "Idols (Male)",
        62: "Isekai",
        63: "Iyashikei",
        64: "Love Polygon",
        75: "Love Status Quo",
        65: "Magical Sex Shift",
        66: "Mahou Shoujo",
        17: "Martial Arts",
        18: "Mecha",
        67: "Medical",
        68: "Memoir",
        38: "Military",
        19: "Music",
        6: "Mythology",
        69: "Organised Crime",
        70: "Otaku Culture",
        20: "Parody",
        71: "Performing Arts",
        72: "Pets",
        40: "Psychological",
        3: "Racing",
        73: "Reincarnation",
        74: "Reverse Harem",
        21: "Samurai",
        23: "School",
        76: "Showbiz",
        29: "Space",
        11: "Strategy Game",
        31: "Super Power",
        77: "Survival",
        78: "Team Sports",
        79: "Time Travel",
        83: "Urban Fantasy",
        32: "Vampire",
        80: "Video Game",
        81: "Villainess",
        82: "Visual Arts",
        48: "Workplace",
    ]
    static let mangaThemeKeys = [50, 51, 52, 53, 54, 44, 55, 39, 56, 57, 58, 35, 59, 13, 60, 61, 62, 63, 64, 75, 65, 66, 17, 18, 67, 68, 38, 19, 6, 69, 70, 20, 71, 72, 40, 3, 73, 74, 21, 23, 76, 29, 11, 31, 77, 78, 79, 83, 32, 80, 81, 82, 48]
    static let mangaDemographics = [
        42: "Josei",
        15: "Kids",
        41: "Seinen",
        25: "Shoujo",
        27: "Shounen",
    ]
    static let mangaDemographicKeys = [42, 15, 41, 25, 27]
    
    static let scoreLabels = [
        "0 - Not yet scored",
        "1 - Appalling",
        "2 - Horrible",
        "3 - Very bad",
        "4 - Bad",
        "5 - Average",
        "6 - Fine",
        "7 - Good",
        "8 - Very good",
        "9 - Great",
        "10 - Masterpiece"
    ]
    
    static let animeRankings: [RankingEnum] = [.all, .tv, .ova, .movie, .special, .bypopularity, .favorite]
    static let mangaRankings: [RankingEnum] = [.all, .manga, .lightnovels, .novels, .oneshots, .manhwa, .manhua, .bypopularity, .favorite]
    
    static let animeStatuses: [StatusEnum] = [.none, .watching, .completed, .onHold, .dropped, .planToWatch]
    static let animeSorts: [SortEnum] = [.listScore, .listUpdatedAt, .animeTitle, .animeStartDate]
    static let mangaStatuses: [StatusEnum] = [.none, .reading, .completed, .onHold, .dropped, .planToRead]
    static let mangaSorts: [SortEnum] = [.listScore, .listUpdatedAt, .mangaTitle, .mangaStartDate]
}
