//
//  AboutView.swift
//  Hako
//
//  Created by Gao Tianrun on 21/5/25.
//

import SwiftUI
import URLMacro

struct AboutView: View {
    var body: some View {
        PageList {
            Section {
                Link("Privacy policy", destination: #URL("https://trgao.github.io/hako/privacypolicy"))
                Link("Terms of service", destination: #URL("https://trgao.github.io/hako/termsofservice"))
            }
            Section("Developer") {
                Link("Gao Tianrun", destination: #URL("https://trgao.github.io"))
            }
            Section {
                Link("MyAnimeList", destination: #URL("https://myanimelist.net"))
                Link("Tenrai API", destination: #URL("https://tenrai.org"))
                Link("AniList", destination: #URL("https://anilist.co/"))
            } header: {
                Text("Data sources")
            } footer: {
                Text("Tenrai API, a third-party service not affiliated with MyAnimeList, is used to fetch data missing from the official API. Occasionally, it may have missing information or the service is down temporarily. These issues are due to the API, not the app itself.")
            }
            Section("Packages") {
                Link("KeychainAccess", destination: #URL("https://github.com/kishikawakatsumi/KeychainAccess"))
                Link("YouTubePlayerKit", destination: #URL("https://github.com/SvenTiigi/YouTubePlayerKit"))
                Link("SystemNotification", destination: #URL("https://github.com/danielsaidi/SystemNotification"))
                Link("FeedKit", destination: #URL("https://github.com/nmdias/FeedKit"))
                Link("WrappingHStack", destination: #URL("https://github.com/ksemianov/WrappingHStack"))
                Link("URLMacro", destination: #URL("https://github.com/alex-npmn/URLMacro"))
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
