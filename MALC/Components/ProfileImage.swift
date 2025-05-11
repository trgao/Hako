//
//  ProfileImage.swift
//  MALC
//
//  Created by Gao Tianrun on 11/5/25.
//

import SwiftUI

struct ProfileImage: View {
    let networker = NetworkManager.shared
    
    var body: some View {
        if let data = UserDefaults.standard.data(forKey: "userImage"), let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 2)
        }
    }
}
