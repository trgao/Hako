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
    @State private var revealed: Set<Int> = []
    private let title: String
    private let text: String?

    init(title: String, text: String?) {
        self.title = title
        self.text = text
    }

    private var collapsedLineLimit: Int {
        screenSize.width >= 600 ? 8 : 4
    }

    var body: some View {
        if let text, !text.isEmpty {
            ScrollViewSection(title: title) {
                let textWithSpoilers = TextWithSpoilers(text, revealed: $revealed)
                VStack {
                    textWithSpoilers
                        .multilineTextAlignment(.leading)
                        .lineLimit(isExpanded ? nil : collapsedLineLimit)
                        .background {
                            textWithSpoilers
                                .lineLimit(collapsedLineLimit)
                                .hidden()
                                .background {
                                    ViewThatFits(in: .vertical) {
                                        textWithSpoilers
                                            .hidden()
                                            .onAppear { canBeExpanded = false }
                                        Color.clear
                                            .onAppear { canBeExpanded = true }
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
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .frame(width: chevronSize, height: chevronSize)
                                .bold()
                                .foregroundStyle(Color(.systemGray2))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .onChange(of: text) {
                    isExpanded = false
                    revealed = []
                }
                .onChange(of: canBeExpanded) {
                    if !canBeExpanded {
                        isExpanded = false
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
                    if !ProcessInfo.processInfo.isMacCatalystApp {
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
}

struct TextWithSpoilers: View {
    @Binding private var revealed: Set<Int>
    private let segments: [Segment]
    
    private enum Segment {
        case plain(String)
        case spoiler(id: Int, text: String)
    }
 
    init(_ text: String, revealed: Binding<Set<Int>>) {
        self.segments = Self.parse(text)
        self._revealed = revealed
    }
    
    // Hidden spoiler content is left out entirely, so VoiceOver can't read it.
    private func render(_ segment: Segment) -> Text {
        switch segment {
        case .plain(let text):
            return Text(.init(text))
        case .spoiler(let id, let text):
            let toggle = Text(.init("[[Spoiler]](hako://openspoiler:\(id))"))
            return revealed.contains(id) ? toggle + Text(.init(text)) : toggle
        }
    }
 
    private static func parse(_ text: String) -> [Segment] {
        var segments: [Segment] = []
        var remaining = text.startIndex
        for (id, match) in text.matches(of: /\[Spoiler[^\]]*\]([\s\S]*?)\[\/Spoiler\]/).enumerated() {
            if match.range.lowerBound > remaining {
                segments.append(.plain(String(text[remaining..<match.range.lowerBound])))
            }
            segments.append(.spoiler(id: id, text: String(match.output.1)))
            remaining = match.range.upperBound
        }
        if remaining < text.endIndex {
            segments.append(.plain(String(text[remaining...])))
        }
        return segments
    }
 
    var body: some View {
        segments.reduce(Text("")) { $0 + render($1) }
            .environment(\.openURL, OpenURLAction { url in
                guard url.scheme == "hako", url.host == "openspoiler", let id = url.port else {
                    return .systemAction
                }
                if revealed.contains(id) {
                    revealed.remove(id)
                } else {
                    revealed.insert(id)
                }
                return .handled
            })
    }
}
