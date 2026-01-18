//
//  TagCloudView.swift
//  Code taken from https://stackoverflow.com/a/62103264
//

import SwiftUI

struct TagCloudView: View {
    @Environment(\.colorScheme) private var colorScheme
    private let tags: [String]
    
    init(tags: [String]) {
        self.tags = tags
    }

    @State private var totalHeight
          = CGFloat.zero

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(Array(self.tags.enumerated()), id: \.offset) { _, tag in
                self.item(for: tag)
                    .padding(.vertical, 5)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if tag == self.tags.last! {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if tag == self.tags.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }.background(viewHeightReader($totalHeight))
    }

    private func item(for text: String) -> some View {
        var color: Color = colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6)
        if text == "Recommended" {
            color = .green
        } else if text == "Not Recommended" {
            color = .red
        } else if text == "Mixed Feelings" {
            color = Color(.systemGray3)
        }
        return
            Text(text)
                .font(.footnote)
                .padding(8)
                .background(color)
                .opacity(0.9)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 3)
        
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
}

