//
//  AboutView.swift
//  Hako
//
//  Created by Gao Tianrun on 21/5/25.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        PageList {
            Section {
                Link("Privacy policy", destination: URL(string: "https://trgao.github.io/hako/privacypolicy")!)
                Link("Terms of service", destination: URL(string: "https://trgao.github.io/hako/termsofservice")!)
            }
            Section("Developer") {
                Link("Gao Tianrun", destination: URL(string: "https://trgao.github.io")!)
            }
            Section("Data sources") {
                Link("MyAnimeList", destination: URL(string: "https://myanimelist.net")!)
                Link("Jikan API", destination: URL(string: "https://jikan.moe")!)
                Link("AniList", destination: URL(string: "https://anilist.co/")!)
            }
            Section("Packages") {
                Link("KeychainAccess", destination: URL(string: "https://github.com/kishikawakatsumi/KeychainAccess")!)
                Link("SwiftUI-Shimmer", destination: URL(string: "https://github.com/markiv/SwiftUI-Shimmer")!)
                Link("YouTubePlayerKit", destination: URL(string: "https://github.com/SvenTiigi/YouTubePlayerKit")!)
                Link("SystemNotification", destination: URL(string: "https://github.com/danielsaidi/SystemNotification")!)
            }
        } photo: {
            Image(uiImage: UIImage(named: "AppIcon.png")!)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } title: {
            Text("Hako")
                .bold()
                .font(.system(size: 25))
                .multilineTextAlignment(.center)
        }
        .handleOpenURLInApp()
    }
}
