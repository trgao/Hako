//
//  UserProfileView.swift
//  Hako
//
//  Created by Gao Tianrun on 17/1/26.
//

import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller: UserProfileViewController
    @StateObject private var networker = NetworkManager.shared
    @State private var hideTitle = true
    @State private var isRefresh = false
    private let user: String
    
    init(user: String) {
        self.user = user
        self._controller = StateObject(wrappedValue: UserProfileViewController(user: user))
    }
    
    var body: some View {
        ZStack {
            if controller.isUserNotFound {
                VStack {
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(.bottom, 10)
                    Text("User not found")
                        .bold()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack {
                        ScrollViewSection {
                            VStack {
                                if #available(iOS 18.0, *) {
                                    Text(user)
                                        .frame(maxWidth: .infinity)
                                        .font(.title3)
                                        .bold()
                                        .onScrollVisibilityChange({ hideTitle = $0 })
                                } else {
                                    Text(user)
                                        .frame(maxWidth: .infinity)
                                        .font(.title3)
                                        .bold()
                                }
                                NavigationLink("Go to user lists") {
                                    UserListView(user: user)
                                }
                                .prominentButtonStyle()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                        }
                        UserStatisticsInformation(userStatistics: controller.userStatistics, loadingState: controller.loadingState)
                        UserFavouritesInformation(anime: controller.anime, manga: controller.manga, characters: controller.characters, people: controller.people, loadingState: controller.favouritesLoadingState, load: controller.loadFavourites)
                    }
                    .padding(.bottom, 20)
                }
                .refreshable {
                    isRefresh = true
                }
                .task(id: isRefresh) {
                    await controller.refresh()
                    isRefresh = false
                }
                .scrollContentBackground(.hidden)
                .background {
                    ImageFrame(id: "", imageUrl: nil, imageSize: .background)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(user)
        .toolbar {
            if hideTitle {
                ToolbarItem(placement: .title) {
                    Text("").hidden()
                }
            }
            if controller.loadingState == .error {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await controller.refresh()
                        }
                    } label: {
                        Image(systemName: "exclamationmark.triangle")
                    }
                }
            }
            if !controller.isUserNotFound {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: URL(string: "https://myanimelist.net/profile/\(user)")!) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}

