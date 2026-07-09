//
//  SentimentEnum.swift
//  Hako
//
//  Created by Gao Tianrun on 9/7/26.
//

import Foundation

enum SentimentEnum: String, Codable {
    case all, recommended, not_recommended, mixed_feelings
    func toString() -> String {
        switch self {
        case .all: return "All"
        case .recommended: return "Recommended"
        case .not_recommended: return "Not recommended"
        case .mixed_feelings: return "Mixed feelings"
        }
    }
    
    func toIcon() -> String {
        switch self {
        case .all: return "bubble"
        case .recommended: return "star.fill"
        case .not_recommended: return "star"
        case .mixed_feelings: return "star.leadinghalf.filled"
        }
    }
}
