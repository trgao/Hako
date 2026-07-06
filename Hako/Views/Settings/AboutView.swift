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
            Section {
                Link("MyAnimeList", destination: URL(string: "https://myanimelist.net")!)
                Link("Tenrai API", destination: URL(string: "https://tenrai.org")!)
                Link("Jikan API", destination: URL(string: "https://jikan.moe")!)
                Link("AniList", destination: URL(string: "https://anilist.co/")!)
            } header: {
                Text("Data sources")
            } footer: {
                Text("Tenrai and Jikan API, which are third-party services not affiliated with MyAnimeList, are used to fetch data missing from the official API. Occasionally, they may have missing information or their services are down temporarily. These issues are due to the API, not the app itself.")
            }
            Section("Packages") {
                Link("KeychainAccess", destination: URL(string: "https://github.com/kishikawakatsumi/KeychainAccess")!)
                Link("YouTubePlayerKit", destination: URL(string: "https://github.com/SvenTiigi/YouTubePlayerKit")!)
                Link("SystemNotification", destination: URL(string: "https://github.com/danielsaidi/SystemNotification")!)
                Link("FeedKit", destination: URL(string: "https://github.com/nmdias/FeedKit")!)
                Link("WrappingHStack", destination: URL(string: "https://github.com/ksemianov/WrappingHStack")!)
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
                .font(.title)
                .multilineTextAlignment(.center)
        }
    }
}
