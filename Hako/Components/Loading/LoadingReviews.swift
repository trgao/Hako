//
//  LoadingReviews.swift
//  Hako
//
//  Created by Gao Tianrun on 14/6/25.
//

import SwiftUI

struct LoadingReviews: View {
    @Environment(\.colorScheme) private var colorScheme
    private let dummyList: [Int]
    private let text = """
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis auctor neque et nunc viverra scelerisque. Donec laoreet et lectus vel semper. Aenean ac pellentesque sem, at fermentum diam. Donec est mi, sodales nec sapien et, ultrices sodales justo. Integer auctor consequat blandit. Nam blandit dictum erat. Phasellus sit amet velit lectus. Ut lacinia sed mauris sed semper. Sed sed egestas tortor. Integer ac ultrices risus, eget sodales nibh. Donec aliquet elit sem, id interdum lacus cursus a. Morbi non faucibus lorem. Vestibulum viverra tincidunt tortor, sit amet fringilla magna suscipit eget. Donec gravida elit lorem, et rutrum lacus maximus in. Duis tincidunt ligula at ornare lobortis. Phasellus pellentesque id sapien sit amet commodo.\nFusce nec aliquam dui, id tempus turpis. In congue nisl quis tristique faucibus. Duis pharetra nunc quam, et varius arcu blandit non. Praesent at auctor tellus, sed cursus sapien. Donec mollis nunc odio, in molestie ante congue at. Curabitur a enim placerat, luctus metus non, laoreet tellus. Nam eleifend, enim eget elementum laoreet, mi nulla gravida purus, sit amet dapibus libero orci non ante. Nullam semper nec tellus at rhoncus. Quisque id nisi vel lorem volutpat dapibus vitae quis urna.
    """
    
    init(length: Int) {
        self.dummyList = Array(0..<length)
    }
    
    var body: some View {
        ForEach(dummyList, id: \.self) { id in
            VStack(alignment: .leading) {
                HStack {
                    ImageFrame(id: "", imageUrl: nil, imageSize: .reviewUser)
                    Text("placeholder ・ placeholder")
                        .font(.caption)
                        .bold()
                        .padding(5)
                }
                .skeleton()
                Text("placeholder")
                    .font(.footnote)
                    .padding(8)
                    .background(colorScheme == .light ? Color(.systemGray6) : Color(.systemBackground))
                    .opacity(0.9)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 3)
                    .skeleton()
                Text(text)
                    .multilineTextAlignment(.leading)
                    .lineLimit(6)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.callout)
                    .skeleton()
            }
            .padding(20)
            .background(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
            .shadow(radius: 0.5)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
