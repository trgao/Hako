//
//  test.swift
//  MALC
//
//  Created by Gao Tianrun on 13/5/25.
//

import SwiftUI

struct test: View {
    var body: some View {
        PageList {
            Text("hello")
        } header: {
            Text("another")
        }
    }
}

#Preview {
    test()
}
