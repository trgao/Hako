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
    private let birthday: String?
    
    init(english: String?, japanese: String? = nil, birthday: String? = nil) {
        self.english = english
        self.japanese = japanese
        self.birthday = birthday
    }
    
    var body: some View {
        VStack {
            if let english = english {
                Text(english)
                    .bold()
                    .font(.system(size: 25))
                    .multilineTextAlignment(.center)
                    .contentShape(Rectangle())
            }
            if let japanese = japanese {
                Text(japanese)
                    .padding(.bottom, 5)
                    .font(.system(size: 18))
                    .opacity(0.7)
                    .multilineTextAlignment(.center)
            }
            if let birthday = birthday {
                Text("Birthday: \(birthday)")
                    .font(.system(size: 18))
                    .opacity(0.7)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 5)
        .contextMenu {
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
        }
    }
}
