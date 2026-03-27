//
//  TagsList.swift
//  Code adapted from https://stackoverflow.com/a/62103264
//

import SwiftUI

struct TagsList: View {
    @State private var totalHeight = CGFloat.zero
    private let tags: [String]
    
    init(tags: [String]) {
        self.tags = tags
    }
    
    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(tags, id: \.self) { tag in
                TagItem(text: tag)
                    .padding(.vertical, 5)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if tag == self.tags.last! {
                            width = 0 // last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { d in
                        let result = height
                        if tag == self.tags.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)
    }
}

struct TagItem: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var settings: SettingsManager
    private let text: String
    private let greenTexts = ["Recommended", "10 ⭐", "9 ⭐", "8 ⭐", "7 ⭐"]
    private let redTexts = ["Not Recommended", "4 ⭐", "3 ⭐", "2 ⭐", "1 ⭐"]
    private let greyTexts = ["Mixed Feelings", "6 ⭐", "5 ⭐"]
    
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        var background: Color {
            if greenTexts.contains(text) {
                return .green
            } else if redTexts.contains(text) {
                return .red
            } else if greyTexts.contains(text) {
                return Color(.systemGray3)
            } else {
                return settings.getAccentColor()
            }
        }
        var textColor: Color {
            if background == .green || background == .teal || background == .orange || background == .green {
                return .black
            } else {
                return .white
            }
        }
        Text(text)
            .font(.footnote)
            .padding(8)
            .foregroundStyle(textColor)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 3)
    }
}
