//
//  NameText.swift
//  Hako
//
//  Created by Gao Tianrun on 7/6/24.
//

import SwiftUI

struct NameText: View {
    private let english: String?
    private let japanese: String?
    
    init(english: String?, japanese: String? = nil) {
        self.english = english
        self.japanese = japanese
    }
    
    var body: some View {
        Menu {
            if let english = english {
                Button {
                    UIPasteboard.general.string = english
                } label: {
                    Text("Copy English name")
                    Text(english)
                }
            }
            if let japanese = japanese {
                Button {
                    UIPasteboard.general.string = japanese
                } label: {
                    Text("Copy Japanese name")
                    Text(japanese)
                }
            }
        } label: {
            VStack {
                if let english = english {
                    Text(english)
                        .bold()
                        .font(.system(size: 25))
                        .padding(.horizontal, 20)
                        .multilineTextAlignment(.center)
                        .contentShape(Rectangle())
                }
                if let japanese = japanese {
                    Text(japanese)
                        .padding(.bottom, 5)
                        .padding(.horizontal, 20)
                        .font(.system(size: 18))
                        .opacity(0.7)
                        .multilineTextAlignment(.center)
                }
            }
        } primaryAction: {}
    }
}
