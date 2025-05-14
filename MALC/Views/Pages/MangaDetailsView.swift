//
//  MangaDetailsView.swift
//  MALC
//
//  Created by Gao Tianrun on 29/4/24.
//

import SwiftUI

struct MangaDetailsView: View {
    @StateObject var controller: MangaDetailsViewController
    @State private var synopsisLines = 4
    @State private var isShowingMore = false
    @State private var isShowingSafariView = false
    @State private var isEditViewPresented = false
    private let id: Int
    private let imageUrl: String?
    private let url: URL
    let networker = NetworkManager.shared
    
    init(id: Int, imageUrl: String?) {
        self.id = id
        self.imageUrl = imageUrl
        self.url = URL(string: "https://myanimelist.net/manga/\(id)")!
        self._controller = StateObject(wrappedValue: MangaDetailsViewController(id: id))
    }
    
    var body: some View {
        ZStack {
            if controller.isLoadingError {
                ErrorView(refresh: controller.refresh)
            } else if let manga = controller.manga {
                PageList {
                    TextBox(title: "Synopsis", text: manga.synopsis)
                    MangaInformation(manga: manga)
                    MangaCharacters(controller: controller)
                    Authors(controller: controller)
                    MangaRelatedItems(controller: controller)
                    Recommendations(mangaRecommendations: manga.recommendations)
                    MangaStatistics(controller: controller)
                } header: {
                    VStack(alignment: .center) {
                        ImageFrame(id: "manga\(manga.id)", imageUrl: manga.mainPicture?.medium, imageSize: .large)
                            .padding([.top], 10)
                        Text(manga.title)
                            .bold()
                            .font(.system(size: 25))
                            .padding(.horizontal, 10)
                            .multilineTextAlignment(.center)
                        if let japaneseTitle = manga.alternativeTitles?.ja {
                            Text(japaneseTitle)
                                .padding([.horizontal, .bottom], 10)
                                .font(.system(size: 18))
                                .opacity(0.7)
                                .multilineTextAlignment(.center)
                        }
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
                        .padding([.bottom], 5)
                        .bold()
                        .font(.system(size: 25))
                        VStack {
                            if let mediaType = manga.mediaType, let status = manga.status {
                                Text("\(mediaType.replacingOccurrences(of: "_", with: " ").capitalized) ・ \(status.replacingOccurrences(of: "_", with: " ").capitalized)")
                            }
                            Text("\(manga.numVolumes == 0 || manga.numVolumes == nil ? "?" : String(manga.numVolumes!)) volumes, \(manga.numChapters == 0 || manga.numChapters == nil ? "?" : String(manga.numChapters!)) chapters")
                        }
                        .opacity(0.7)
                        .font(.system(size: 12))
                        
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
                    Text("Nothing found. ")
                        .bold()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(.secondarySystemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $isShowingSafariView) {
            SafariView(url: url)
        }
        .toolbar {
            if networker.isSignedIn {
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
                        MangaEditView(id: manga.id, listStatus: manga.myListStatus, title: manga.title, numVolumes: manga.numVolumes, numChapters: manga.numChapters, imageUrl: imageUrl, isPresented: $isEditViewPresented)
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
                Button {
                    isShowingSafariView = true
                } label: {
                    Label("Open in browser", systemImage: "globe")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .disabled(controller.isLoading)
        }
    }
}
