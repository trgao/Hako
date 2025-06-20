//
//  Synopsis.swift
//  Hako
//
//  Created by Gao Tianrun on 20/6/25.
//

import SwiftUI
import Translation

struct Synopsis: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isExpanded = false
    @State private var canBeExpanded = false
    @State private var showTranslation = false
    private let text: String?
    
    init(text: String?) {
        self.text = text
    }
    
    var body: some View {
        if let text = text, !text.isEmpty {
            ScrollViewSection(title: "Synopsis") {
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
                        .translationPresentation(isPresented: $showTranslation,
                                                 text: text)
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
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
                .contextMenu {
                    Button {
                        UIPasteboard.general.string = text
                    } label: {
                        Label("Copy", systemImage: "document.on.document")
                    }
                    Button {
                        showTranslation = true
                    } label: {
                        Label("Translate", systemImage: "translate")
                    }
                }
            }
        }
    }
}
