//
//  ObservableBox.swift
//  Hako
//
//  Created by Gao Tianrun on 4/11/26.
//

import SwiftUI

@Observable
final class ObservableBox<T> {
    var value: T
    init(_ value: T) { self.value = value }
}
