//
//  GroupDetailsView.swift
//  MALC
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct GroupDetailsView: View {
    private let item: MALItem
    private let urlExtend: String
    private let type: TypeEnum
    
    init(item: MALItem, urlExtend: String, type: TypeEnum) {
        self.item = item
        self.urlExtend = urlExtend
        self.type = type
    }
    
    var body: some View {
        JikanGridInfiniteScrollView(title: item.name, urlExtend: urlExtend, type: type)
    }
}
