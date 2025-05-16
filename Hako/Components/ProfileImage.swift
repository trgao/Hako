//
//  ProfileImage.swift
//  Hako
//
//  Created by Gao Tianrun on 11/5/25.
//

import SwiftUI

struct ProfileImage: View {
    @StateObject private var controller: ImageFrameController
//    let networker = NetworkManager.shared
    
    init() {
        self._controller = StateObject(wrappedValue: ImageFrameController(id: "userImage", imageUrl: NetworkManager.shared.imageUrlMap["userImage"]))
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
                .onAppear {
                    UserDefaults.standard.set(data, forKey: "userImage")
                }
        } else {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.gray)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 2)
        }
    }
}
