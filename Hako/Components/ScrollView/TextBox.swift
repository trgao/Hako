//
//  TextBox.swift
//  Hako
//
//  Created by Gao Tianrun on 20/6/25.
//

import SwiftUI
import Translation

struct TextBox: View {
    @Environment(\.screenSize) private var screenSize
    @Environment(\.colorScheme) private var colorScheme
    @ScaledMetric private var chevronSize = 30
    @State private var isExpanded = false
    @State private var canBeExpanded = false
    @State private var showTranslation = false
    private let title: String
    private let text: String?
    
    init(title: String, text: String?) {
        self.title = title
        self.text = text
    }
    
    var body: some View {
        if let text = text, !text.isEmpty {
            ScrollViewSection(title: title) {
                VStack {
                    TextWithSpoilers(text)
                        .multilineTextAlignment(.leading)
                        .lineLimit(isExpanded ? nil : (screenSize.width >= 600 ? 8 : 4))
                        .background {
                            ViewThatFits(in: .vertical) {
                                Text(.init(text))
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
                        .translationPresentation(isPresented: $showTranslation, text: text)
                    if canBeExpanded {
                        Button {
                            isExpanded.toggle()
                        } label: {
                            VStack {
                                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                    .frame(width: chevronSize, height: chevronSize)
                            }
                            .bold()
                            .foregroundStyle(Color(.systemGray2))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
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

struct TextSegment {
    var isSpoiler: Bool
    var text: String
    var i: Int
}

struct TextWithSpoilers: View {
    @State private var texts: [TextSegment]
    @State private var showing: [Bool]
    
    init(_ text: String) {
        let regexMatches = text.matches(of: /\[spoiler[^\]]*\]([\s\S]*?)\[\/spoiler\]/)
        var prev = String.Index(utf16Offset: 0, in: text)
        var texts: [TextSegment] = []
        var showing: [Bool] = []
        var i = 0
        for match in regexMatches {
            if match.range.lowerBound != prev {
                texts.append(TextSegment(isSpoiler: false, text: String(text[prev..<match.range.lowerBound]), i: -1))
            }
            showing.append(false)
            texts.append(TextSegment(isSpoiler: true, text: String(match.output.1), i: i))
            prev = match.range.upperBound
            i += 1
        }
        texts.append(TextSegment(isSpoiler: false, text: String(text[prev..<text.endIndex]), i: -1))
        self.texts = texts
        self.showing = showing
    }
    
    var body: some View {
        texts.map {
            if $0.isSpoiler {
                return Text(.init("[[Spoiler]](hako://openspoiler:\($0.i))")) + Text(.init($0.text)).foregroundStyle($0.i < showing.count && showing[$0.i] ? .primary : Color.clear).font($0.i < showing.count && showing[$0.i] ? .body : .system(size: 0.01))
            } else {
                return Text(.init($0.text))
            }
        }.reduce(Text(""), +)
        .onOpenURL { url in
            if let i = url.port, i < showing.count {
                showing[i].toggle()
            }
        }
    }
}
