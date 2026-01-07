//
//  StatusEnum.swift
//  Hako
//
//  Created by Gao Tianrun on 15/5/24.
//

import SwiftUI

enum StatusEnum: Codable {
    case watching, completed, onHold, dropped, planToWatch, reading, planToRead, none
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let status = try? container.decode(String.self)
        self = .init(text: status)
    }
    
    init(text: String?) {
        switch text {
        case "watching": self = .watching
        case "completed": self = .completed
        case "on_hold": self = .onHold
        case "dropped": self = .dropped
        case "plan_to_watch": self = .planToWatch
        case "reading": self = .reading
        case "plan_to_read": self = .planToRead
        default:
            self = .none
        }
    }
    
    func toParameter() -> String {
        switch self {
        case .watching:
            return "watching"
        case .completed:
            return "completed"
        case .onHold:
            return "on_hold"
        case .dropped:
            return "dropped"
        case .planToWatch:
            return "plan_to_watch"
        case .reading:
            return "reading"
        case .planToRead:
            return "plan_to_read"
        default:
            return ""
        }
    }
    
    func toString() -> String {
        switch self {
        case .none:
            return "All"
        case .watching:
            return "Watching"
        case .completed:
            return "Completed"
        case .onHold:
            return "On hold"
        case .dropped:
            return "Dropped"
        case .planToWatch:
            return "Plan to watch"
        case .reading:
            return "Reading"
        case .planToRead:
            return "Plan to read"
        }
    }
    
    func toColour() -> Color {
        switch self {
        case .watching:
            return Color(.systemGreen)
        case .completed:
            return Color(.systemBlue)
        case .onHold:
            return Color(.systemYellow)
        case .dropped:
            return Color(.systemRed)
        case .planToWatch:
            return .primary
        case .reading:
            return Color(.systemGreen)
        case .planToRead:
            return .primary
        default:
            return .primary
        }
    }
}
