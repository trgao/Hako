//
//  ProfileImage.swift
//  Hako
//
//  Created by Gao Tianrun on 11/5/25.
//

import SwiftUI

struct ProfileImage: View {
    @StateObject private var controller: ImageFrameController
    
    init(imageUrl: String?) {
        self._controller = StateObject(wrappedValue: ImageFrameController(id: "userImage", imageUrl: imageUrl, isProfile: true))
    }
    
    var body: some View {
        if let data = UserDefaults.standard.data(forKey: "userImage"), let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 2)
        } else if let data = controller.image, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 2)
        } else {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.gray)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 2)
        }
    }
}
