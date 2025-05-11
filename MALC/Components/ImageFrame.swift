//
//  ImageFrame.swift
//  MALC
//
//  Created by Gao Tianrun on 29/4/24.
//

import SwiftUI

struct ImageFrame: View {
    @StateObject private var controller: ImageFrameController
    private let width: CGFloat
    private let height: CGFloat
    let networker = NetworkManager.shared
    
    init(id: String, imageUrl: String?, width: CGFloat, height: CGFloat) {
        self._controller = StateObject(wrappedValue: ImageFrameController(id: id, imageUrl: imageUrl))
        self.width = width
        self.height = height
    }
    
    var body: some View {
        if let data = controller.image, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 2)
        } else {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.gray)
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 2)
        }
    }
}
