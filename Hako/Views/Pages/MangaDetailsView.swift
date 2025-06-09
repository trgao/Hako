//
//  MangaDetailsView.swift
//  Hako
//
//  Created by Gao Tianrun on 29/4/24.
//

import SwiftUI

struct MangaDetailsView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject var controller: MangaDetailsViewController
    @State private var synopsisLines = 4
    @State private var isShowingMore = false
    @State private var isEditViewPresented = false
    @State private var isRefresh = false
    private let id: Int
    private let url: URL
    private let colours: [StatusEnum:Color] = [
        .reading: Color(.systemGreen),
        .completed: Color(.systemBlue),
        .onHold: Color(.systemYellow),
        .dropped: Color(.systemRed),
        .planToRead: .primary,
        .none: Color(.systemGray)
    ]
    let networker = NetworkManager.shared
    
    init(id: Int) {
        self.id = id
        self.url = URL(string: "https://myanimelist.net/manga/\(id)")!
        self._controller = StateObject(wrappedValue: MangaDetailsViewController(id: id))
    }
    
    var body: some View {
        ZStack {
            if controller.isLoadingError && controller.manga == nil {
                ErrorView(refresh: controller.refresh)
            } else if let manga = controller.manga {
                PageList {
                    TextBox(title: "Synopsis", text: manga.synopsis)
                    if let listStatus = manga.myListStatus, networker.isSignedIn && !settings.hideMangaProgress {
                        Section {
                            if settings.mangaReadProgress == 0 {
                                if let numChapters = manga.numChapters, numChapters > 0 {
                                    VStack {
                                        ProgressView(value: Float(listStatus.numChaptersRead) / Float(numChapters))
                                            .tint(colours[listStatus.status ?? .none])
                                        HStack {
                                            Text(listStatus.status?.toString() ?? "")
                                                .bold()
                                            Spacer()
                                            if let numVolumes = manga.numVolumes, numVolumes > 0 {
                                                Label("\(String(listStatus.numVolumesRead)) / \(String(numVolumes))", systemImage: "book.closed.fill")
                                                    .labelStyle(CustomLabel(spacing: 2))
                                            } else {
                                                Label("\(String(listStatus.numVolumesRead)) / ?", systemImage: "book.closed.fill")
                                                    .labelStyle(CustomLabel(spacing: 2))
                                            }
                                            Label("\(String(listStatus.numChaptersRead)) / \(String(numChapters))", systemImage: "book.pages.fill")
                                                .labelStyle(CustomLabel(spacing: 2))
                                        }
                                    }
                                    .padding(.vertical, 10)
                                } else {
                                    VStack {
                                        ProgressView(value: listStatus.numChaptersRead == 0 ? 0 : 0.5)
                                            .tint(colours[listStatus.status ?? .none])
                                        HStack {
                                            Text(listStatus.status?.toString() ?? "")
                                                .bold()
                                            Spacer()
                                            if let numVolumes = manga.numVolumes, numVolumes > 0 {
                                                Label("\(String(listStatus.numVolumesRead)) / \(String(numVolumes))", systemImage: "book.closed.fill")
                                                    .labelStyle(CustomLabel(spacing: 2))
                                            } else {
                                                Label("\(String(listStatus.numVolumesRead)) / ?", systemImage: "book.closed.fill")
                                                    .labelStyle(CustomLabel(spacing: 2))
                                            }
                                            Label("\(String(listStatus.numChaptersRead)) / ?", systemImage: "book.pages.fill")
                                                .labelStyle(CustomLabel(spacing: 2))
                                        }
                                    }
                                    .padding(.vertical, 10)
                                }
                            } else {
                                if let numVolumes = manga.numVolumes, numVolumes > 0 {
                                    VStack {
                                        ProgressView(value: Float(listStatus.numVolumesRead) / Float(numVolumes))
                                            .tint(colours[listStatus.status ?? .none])
                                        HStack {
                                            Text(listStatus.status?.toString() ?? "")
                                                .bold()
                                            Spacer()
                                            Label("\(String(listStatus.numVolumesRead)) / \(String(numVolumes))", systemImage: "book.closed.fill")
                                                .labelStyle(CustomLabel(spacing: 2))
                                            if let numChapters = manga.numChapters, numChapters > 0 {
                                                Label("\(String(listStatus.numChaptersRead)) / \(String(numChapters))", systemImage: "book.pages.fill")
                                                    .labelStyle(CustomLabel(spacing: 2))
                                            } else {
                                                Label("\(String(listStatus.numChaptersRead)) / ?", systemImage: "book.pages.fill")
                                                    .labelStyle(CustomLabel(spacing: 2))
                                            }
                                        }
                                    }
                                    .padding(.vertical, 10)
                                } else {
                                    VStack {
                                        ProgressView(value: listStatus.numVolumesRead == 0 ? 0 : 0.5)
                                            .tint(colours[listStatus.status ?? .none])
                                        HStack {
                                            Text(listStatus.status?.toString() ?? "")
                                                .bold()
                                            Spacer()
                                            Label("\(String(listStatus.numVolumesRead)) / ?", systemImage: "book.closed.fill")
                                                .labelStyle(CustomLabel(spacing: 2))
                                            if let numChapters = manga.numChapters, numChapters > 0 {
                                                Label("\(String(listStatus.numChaptersRead)) / \(String(numChapters))", systemImage: "book.pages.fill")
                                                    .labelStyle(CustomLabel(spacing: 2))
                                            } else {
                                                Label("\(String(listStatus.numChaptersRead)) / ?", systemImage: "book.pages.fill")
                                                    .labelStyle(CustomLabel(spacing: 2))
                                            }
                                        }
                                    }
                                    .padding(.vertical, 10)
                                }
                            }
                        } header: {
                            Text("Your progress")
                                .textCase(nil)
                                .foregroundColor(Color.primary)
                                .font(.system(size: 17))
                                .bold()
                        }
                    }
                    MangaInformation(manga: manga)
                    if !settings.hideMangaCharacters {
                        MangaCharacters(controller: controller)
                    }
                    if !settings.hideAuthors {
                        Authors(controller: controller)
                    }
                    if !settings.hideMangaRelated {
                        MangaRelatedItems(controller: controller)
                    }
                    if !settings.hideMangaRecommendations {
                        Recommendations(mangaRecommendations: manga.recommendations)
                    }
                    if !settings.hideMangaStatistics {
                        MangaStatistics(controller: controller)
                    }
                } header: {
                    ImageFrame(id: "manga\(manga.id)", imageUrl: controller.manga?.mainPicture?.large, imageSize: .large)
                        .padding(.top, 10)
                    TitleText(romaji: manga.title, english: manga.alternativeTitles?.en, japanese: manga.alternativeTitles?.ja)
                    HStack {
                        VStack {
                            if let myScore = manga.myListStatus?.score, myScore > 0 {
                                Text("MAL score:")
                                    .font(.system(size: 13))
                            }
                            Text("\(manga.mean == nil ? "N/A" : String(manga.mean!)) ⭐")
                        }
                        if let myScore = manga.myListStatus?.score, myScore > 0 {
                            VStack {
                                Text("Your score:")
                                    .font(.system(size: 13))
                                Text("\(myScore) ⭐")
                            }
                            .padding(.leading, 20)
                        }
                    }
                    .bold()
                    .font(.system(size: 25))
                    VStack {
                        if let mediaType = manga.mediaType, let status = manga.status {
                            Text("\(mediaType.replacingOccurrences(of: "_", with: " ").capitalized) ・ \(status.formatStatus())")
                        }
                        Text("\(manga.numVolumes == 0 || manga.numVolumes == nil ? "?" : String(manga.numVolumes!)) volumes, \(manga.numChapters == 0 || manga.numChapters == nil ? "?" : String(manga.numChapters!)) chapters")
                    }
                    .opacity(0.7)
                    .font(.system(size: 12))
                }
                .task(id: isRefresh) {
                    if isRefresh {
                        await controller.refresh()
                        isRefresh = false
                    }
                }
                .refreshable {
                    isRefresh = true
                }
                .scrollContentBackground(settings.translucentBackground ? .hidden : .visible)
                .background {
                    if settings.translucentBackground {
                        ImageFrame(id: "manga\(id)", imageUrl: controller.manga?.mainPicture?.large, imageSize: .background)
                    }
                }
            }
            if controller.isLoading {
                LoadingView()
            }
            if controller.manga == nil && !controller.isLoading && !controller.isLoadingError {
                VStack {
                    Image(systemName: "book.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                    Text("Nothing found")
                        .bold()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(.secondarySystemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if networker.isSignedIn && !settings.useWithoutAccount {
                if let manga = controller.manga {
                    Button {
                        isEditViewPresented = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .sheet(isPresented: $isEditViewPresented) {
                        Task {
                            await controller.refresh()
                        }
                    } content: {
                        MangaEditView(id: manga.id, listStatus: manga.myListStatus, title: manga.title, numVolumes: manga.numVolumes, numChapters: manga.numChapters, imageUrl: controller.manga?.mainPicture?.large)
                            .presentationBackground {
                                if settings.translucentBackground {
                                    ImageFrame(id: "manga\(id)", imageUrl: controller.manga?.mainPicture?.large, imageSize: .background)
                                } else {
                                    Color(.systemGray6)
                                }
                            }
                    }
                    .disabled(controller.isLoading)
                } else {
                    Button {} label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .disabled(true)
                }
            }
            Menu {
                ShareLink("Share", item: url)
                Link(destination: url) {
                    Label("Open in browser", systemImage: "globe")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .handleOpenURLInApp()
            .disabled(controller.isLoading)
        }
    }
}
