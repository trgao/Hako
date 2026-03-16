//
//  LoadingReviews.swift
//  Hako
//
//  Created by Gao Tianrun on 14/6/25.
//

import SwiftUI

struct LoadingReviews: View {
    private let dummyList: [Int]
    
    init(length: Int) {
        self.dummyList = Array(0..<length)
    }
    
    var body: some View {
        ForEach(dummyList, id: \.self) { id in
            PlaceholderReview()
        }
    }
}
