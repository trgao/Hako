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
    
    var text: some View {
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
        .frame(maxWidth: .infinity, alignment: .center)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    var body: some View {
        text
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
            .contextMenu {
                if let english = english, !english.isEmpty {
                    Button {
                        UIPasteboard.general.string = english
                    } label: {
                        Text("Copy english name")
                        Text(english)
                    }
                }
                if let japanese = japanese, !japanese.isEmpty {
                    Button {
                        UIPasteboard.general.string = japanese
                    } label: {
                        Text("Copy native language name")
                        Text(japanese)
                    }
                }
                if let birthday = birthday, !birthday.isEmpty {
                    Button {
                        UIPasteboard.general.string = birthday
                    } label: {
                        Text("Copy birthday")
                        Text(birthday)
                    }
                }
            }
    }
}
