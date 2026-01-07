//
//  ViewItem.swift
//  Hako
//
//  Created by Gao Tianrun on 6/1/26.
//

import Foundation

struct ViewItem: Hashable {
    let type: ViewTypeEnum
    let id: Int
    var name: String? = nil
}
