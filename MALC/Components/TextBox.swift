//
//  TextBox.swift
//  MALC
//
//  Created by Gao Tianrun on 29/4/24.
//

import SwiftUI

struct TextBox: View {
    @State private var isExpanded = false
    @State private var canBeExpanded = false
    private let title: String
    private let text: String?
    
    init(title: String, text: String?) {
        self.title = title
        self.text = text
    }
    
    var body: some View {
        if let text = text {
            Section {
                VStack {
                    Text(text)
                        .multilineTextAlignment(.leading)
                        .lineLimit(isExpanded ? nil : 4)
                        .background {
                            ViewThatFits(in: .vertical) {
                                Text(text)
                                    .hidden()
                                Color.clear
                                    .onAppear {
                                        canBeExpanded = true
                                    }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(5)
                        .lineSpacing(2)
                    if canBeExpanded {
                        Button {
                            isExpanded.toggle()
                        } label: {
                            if isExpanded {
                                Image(systemName: "chevron.up")
                            } else {
                                Image(systemName: "chevron.down")
                            }
                        }
                        .bold()
                        .buttonStyle(.plain)
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color(.systemGray2))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            } header: {
                Text(title)
                    .textCase(nil)
                    .foregroundColor(Color.primary)
                    .font(.system(size: 17))
                    .bold()
            }
        }
    }
}
