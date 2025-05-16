//
//  MangaListItem.swift
//  MALC
//
//  Created by Gao Tianrun on 11/5/25.
//

import SwiftUI

struct MangaListItem: View {
    @State private var isEditViewPresented = false
    @Binding private var isBack: Bool
    private let manga: MALListManga
    private let colours: [StatusEnum:Color] = [
        .reading: Color(.systemGreen),
        .completed: Color(.systemBlue),
        .onHold: Color(.systemYellow),
        .dropped: Color(.systemRed),
        .planToRead: Color(.systemGray),
        .none: Color(.systemBlue)
    ]
    private let refresh: () async -> Void
    let networker = NetworkManager.shared
    
    init(manga: MALListManga) {
        self.manga = manga
        self.refresh = {}
        self._isBack = .constant(false)
    }
    
    init(manga: MALListManga, status: StatusEnum, refresh: @escaping () async -> Void, isBack: Binding<Bool>) {
        self.manga = manga
        self.refresh = refresh
        self._isBack = isBack
    }
    
    var body: some View {
        NavigationLink {
            MangaDetailsView(id: manga.id, imageUrl: manga.node.mainPicture?.medium)
                .onAppear {
                    isBack = false
                }
                .onDisappear {
                    isBack = true
                }
        } label: {
            HStack {
                ImageFrame(id: "manga\(manga.id)", imageUrl: manga.node.mainPicture?.medium, imageSize: .small)
                VStack(alignment: .leading) {
                    Text(manga.node.title)
                        .bold()
                        .font(.system(size: 16))
                    if let numChaptersRead = manga.listStatus?.numChaptersRead, let numVolumesRead = manga.listStatus?.numVolumesRead {
                        if let numVolumes = manga.node.numVolumes, numVolumes > 0 {
                            VStack(alignment: .leading) {
                                ProgressView(value: Float(numVolumesRead) / Float(numVolumes))
                                    .tint(colours[manga.listStatus?.status ?? .none])
                                HStack {
                                    Label("\(String(numVolumesRead)) / \(String(numVolumes))", systemImage: "book.closed.fill")
                                        .font(.system(size: 13))
                                        .foregroundStyle(Color(.systemGray))
                                        .labelStyle(CustomLabel(spacing: 2))
                                    if let numChapters = manga.node.numChapters, numChapters > 0 {
                                        Label("\(String(numChaptersRead)) / \(String(numChapters))", systemImage: "book.pages.fill")
                                            .font(.system(size: 13))
                                            .foregroundStyle(Color(.systemGray))
                                            .labelStyle(CustomLabel(spacing: 2))
                                    } else {
                                        Label("\(String(numChaptersRead)) / ?", systemImage: "book.pages.fill")
                                            .font(.system(size: 13))
                                            .foregroundStyle(Color(.systemGray))
                                            .labelStyle(CustomLabel(spacing: 2))
                                    }
                                }
                            }
                        } else if let numChapters = manga.node.numChapters, numChapters > 0 {
                            VStack(alignment: .leading) {
                                ProgressView(value: Float(numChaptersRead) / Float(numChapters))
                                    .tint(colours[manga.listStatus?.status ?? .none])
                                HStack {
                                    if let numVolumes = manga.node.numVolumes, numVolumes > 0 {
                                        Label("\(String(numVolumesRead)) / \(String(numVolumes))", systemImage: "book.closed.fill")
                                            .font(.system(size: 13))
                                            .foregroundStyle(Color(.systemGray))
                                            .labelStyle(CustomLabel(spacing: 2))
                                    } else {
                                        Label("\(String(numVolumesRead)) / ?", systemImage: "book.closed.fill")
                                            .font(.system(size: 13))
                                            .foregroundStyle(Color(.systemGray))
                                            .labelStyle(CustomLabel(spacing: 2))
                                    }
                                    Label("\(String(numChaptersRead)) / \(String(numChapters))", systemImage: "book.pages.fill")
                                        .font(.system(size: 13))
                                        .foregroundStyle(Color(.systemGray))
                                        .labelStyle(CustomLabel(spacing: 2))
                                }
                            }
                        } else {
                            VStack(alignment: .leading) {
                                ProgressView(value: numChaptersRead == 0 ? 0 : 0.5)
                                    .tint(colours[manga.listStatus?.status ?? .none])
                                HStack {
                                    if let numVolumes = manga.node.numVolumes, numVolumes > 0 {
                                        Label("\(String(numVolumesRead)) / \(String(numVolumes))", systemImage: "book.closed.fill")
                                            .font(.system(size: 13))
                                            .foregroundStyle(Color(.systemGray))
                                            .labelStyle(CustomLabel(spacing: 2))
                                    } else {
                                        Label("\(String(numVolumesRead)) / ?", systemImage: "book.closed.fill")
                                            .font(.system(size: 13))
                                            .foregroundStyle(Color(.systemGray))
                                            .labelStyle(CustomLabel(spacing: 2))
                                    }
                                    Label("\(String(numChaptersRead)) / ?", systemImage: "book.pages.fill")
                                        .font(.system(size: 13))
                                        .foregroundStyle(Color(.systemGray))
                                        .labelStyle(CustomLabel(spacing: 2))
                                }
                            }
                        }
                    }
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(manga.node.status?.formatStatus() ?? "")
                                .opacity(0.7)
                                .font(.system(size: 12))
                            if let score = manga.listStatus?.score, score > 0 {
                                Text("\(score) ⭐")
                                    .bold()
                                    .font(.system(size: 13))
                            }
                        }
                        Spacer()
                        if networker.isSignedIn && manga.listStatus != nil {
                            Button {
                                isEditViewPresented = true
                            } label: {
                                Image(systemName: "square.and.pencil")
                            }
                            .buttonStyle(.bordered)
                            .foregroundStyle(Color(.systemBlue))
                            .sheet(isPresented: $isEditViewPresented) {
                                Task {
                                    await refresh()
                                }
                            } content: {
                                MangaEditView(id: manga.id, listStatus: manga.listStatus, title: manga.node.title, numVolumes: manga.node.numVolumes, numChapters: manga.node.numChapters, imageUrl: manga.node.mainPicture?.medium, isPresented: $isEditViewPresented)
                            }
                        }
                    }
                }
                .padding(5)
            }
        }
        .padding(5)
    }
}
