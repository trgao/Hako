//
//  AniListScheduleResponse.swift
//  Hako
//
//  Created by Gao Tianrun on 3/4/26.
//

import Foundation

struct AniListScheduleResponse: Codable {
    struct Data: Codable {
        struct Page: Codable {
            let airingSchedules: [AiringSchedule]
        }
        
        let Page: Page
    }
    
    let data: Data
}
