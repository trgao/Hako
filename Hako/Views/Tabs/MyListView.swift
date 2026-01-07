//
//  MyListView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import SystemNotification

struct MyListView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller = MyListViewController()
    @StateObject private var networker = NetworkManager.shared
    @State private var isInit = false
    @State private var isRefresh = false
    @Binding private var id: UUID
    @Binding private var type: TypeEnum?
    @Binding private var animeStatus: StatusEnum?
    @Binding private var animeSort: String?
    @Binding private var mangaStatus: StatusEnum?
    @Binding private var mangaSort: String?
    
    @State private var selectedAnime: MALListAnime?
    @State private var selectedAnimeIndex: Int?
    @State private var isAnimeDeleted = false
    @State private var animeListStatus: MyListStatus?
    
    @State private var selectedManga: MALListManga?
    @State private var selectedMangaIndex: Int?
    @State private var isMangaDeleted = false
    @State private var mangaListStatus: MyListStatus?
    
    init(id: Binding<UUID>, type: Binding<TypeEnum?>, animeStatus: Binding<StatusEnum?>, animeSort: Binding<String?>, mangaStatus: Binding<StatusEnum?>, mangaSort: Binding<String?>) {
        self._id = id
        self._type = type
        self._animeStatus = animeStatus
        self._animeSort = animeSort
        self._mangaStatus = mangaStatus
        self._mangaSort = mangaSort
    }
    
    var filter: some View {
        Menu {
            if controller.type == .anime {
                Picker(selection: $controller.animeStatus, label: Text("Status")) {
                    Label("All", systemImage: "circle.circle").tag(StatusEnum.none)
                    Label("Watching", systemImage: "play.circle").tag(StatusEnum.watching)
                    Label("Completed", systemImage: "checkmark.circle").tag(StatusEnum.completed)
                    Label("On hold", systemImage: "pause.circle").tag(StatusEnum.onHold)
                    Label("Dropped", systemImage: "minus.circle").tag(StatusEnum.dropped)
                    Label("Plan to watch", systemImage: "plus.circle.dashed").tag(StatusEnum.planToWatch)
                }
                .onChange(of: controller.animeStatus) {
                    Task {
                        await controller.refreshAnime()
                    }
                }
                Divider()
                Picker(selection: $controller.animeSort, label: Text("Sort")) {
                    Label("By score", systemImage: "star").tag("list_score")
                    Label("By last update", systemImage: "arrow.trianglehead.clockwise.rotate.90").tag("list_updated_at")
                    Label("By title", systemImage: "character").tag("anime_title")
                    Label("By start date", systemImage: "calendar").tag("anime_start_date")
                }
                .onChange(of: controller.animeSort) {
                    Task {
                        await controller.refreshAnime()
                    }
                }
            } else if controller.type == .manga {
                Picker(selection: $controller.mangaStatus, label: Text("Status")) {
                    Label("All", systemImage: "circle.circle").tag(StatusEnum.none)
                    Label("Reading", systemImage: "book.circle").tag(StatusEnum.reading)
                    Label("Completed", systemImage: "checkmark.circle").tag(StatusEnum.completed)
                    Label("On hold", systemImage: "pause.circle").tag(StatusEnum.onHold)
                    Label("Dropped", systemImage: "minus.circle").tag(StatusEnum.dropped)
                    Label("Plan to read", systemImage: "plus.circle.dashed").tag(StatusEnum.planToRead)
                }
                .onChange(of: controller.mangaStatus) {
                    Task {
                        await controller.refreshManga()
                    }
                }
                Divider()
                Picker(selection: $controller.mangaSort, label: Text("Sort")) {
                    Label("By score", systemImage: "star").tag("list_score")
                    Label("By last update", systemImage: "arrow.trianglehead.clockwise.rotate.90").tag("list_updated_at")
                    Label("By title", systemImage: "character").tag("manga_title")
                    Label("By start date", systemImage: "calendar").tag("manga_start_date")
                }
                .onChange(of: controller.mangaSort) {
                    Task {
                        await controller.refreshManga()
                    }
                }
            }
        } label: {
            Button{} label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
            }
        }
    }
    
    var animeList: some View {
        VStack {
            if controller.isAnimeLoading && controller.animeItems.isEmpty {
                List {
                    Section(controller.animeStatus.toString()) {
                        LoadingList(length: 20)
                            .id(controller.animeLoadId)
                    }
                }
                .disabled(true)
            } else {
                List {
                    Section(controller.animeStatus.toString()) {
                        if controller.isLoadingError && controller.animeItems.isEmpty {
                            ListErrorView(refresh: { await controller.refreshAnime() })
                        } else if !controller.isAnimeLoading && controller.animeItems.isEmpty {
                            VStack {
                                Image(systemName: "tv.fill")
                                    .resizable()
                                    .frame(width: 45, height: 40)
                                Text("Nothing found")
                                    .bold()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 50)
                        } else {
                            ForEach(Array(controller.animeItems.enumerated()), id: \.1.id) { index, item in
                                AnimeListItem(anime: item, selectedAnime: $selectedAnime, selectedAnimeIndex: $selectedAnimeIndex, index: index)
                                    .onAppear {
                                        Task {
                                            await controller.loadMoreIfNeeded(index: index)
                                        }
                                    }
                                    .swipeActions(edge: .leading) {
                                        if settings.useSwipeActions && !controller.isLoading {
                                            if var listStatus = item.listStatus, listStatus.numEpisodesWatched > 0 {
                                                Button {
                                                    Task {
                                                        listStatus.numEpisodesWatched -= 1
                                                        await controller.updateAnime(index: index, id: item.id, listStatus: listStatus)
                                                    }
                                                } label: {
                                                    Label("-1 episode watched", systemImage: "minus.circle")
                                                }
                                            }
                                        }
                                    }
                                    .swipeActions(edge: .trailing) {
                                        if settings.useSwipeActions && !controller.isLoading {
                                            if var listStatus = item.listStatus, item.node.numEpisodes == nil || item.node.numEpisodes == 0 || listStatus.numEpisodesWatched < (item.node.numEpisodes ?? .max) {
                                                Button {
                                                    Task {
                                                        listStatus.numEpisodesWatched += 1
                                                        await controller.updateAnime(index: index, id: item.id, listStatus: listStatus)
                                                    }
                                                } label: {
                                                    Label("+1 episode watched", systemImage: "plus.circle")
                                                }
                                            }
                                        }
                                    }
                            }
                        }
                        if controller.isAnimeLoading {
                            LoadingList(length: 5)
                                .id(controller.animeLoadId)
                        }
                    }
                }
            }
        }
    }
    
    var mangaList: some View {
        VStack {
            if controller.isMangaLoading && controller.mangaItems.isEmpty {
                List {
                    Section(controller.mangaStatus.toString()) {
                        LoadingList(length: 20)
                            .id(controller.mangaLoadId)
                    }
                }
                .disabled(true)
            } else {
                List {
                    Section(controller.mangaStatus.toString()) {
                        if controller.isLoadingError && controller.mangaItems.isEmpty {
                            ListErrorView(refresh: { await controller.refreshManga() })
                        } else if !controller.isMangaLoading && controller.mangaItems.isEmpty {
                            VStack {
                                Image(systemName: "book.fill")
                                    .resizable()
                                    .frame(width: 45, height: 40)
                                Text("Nothing found")
                                    .bold()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 50)
                        } else {
                            ForEach(Array(controller.mangaItems.enumerated()), id: \.1.id) { index, item in
                                MangaListItem(manga: item, selectedManga: $selectedManga, selectedMangaIndex: $selectedMangaIndex, index: index)
                                    .onAppear {
                                        Task {
                                            await controller.loadMoreIfNeeded(index: index)
                                        }
                                    }
                                    .swipeActions(edge: .leading) {
                                        if settings.useSwipeActions && !controller.isLoading {
                                            if settings.mangaReadProgress == 0 {
                                                if var listStatus = item.listStatus, listStatus.numChaptersRead > 0 {
                                                    Button {
                                                        Task {
                                                            listStatus.numChaptersRead -= 1
                                                            await controller.updateManga(index: index, id: item.id, listStatus: listStatus)
                                                        }
                                                    } label: {
                                                        Label("-1 chapter read", systemImage: "minus.circle")
                                                    }
                                                }
                                            } else if var listStatus = item.listStatus, listStatus.numVolumesRead > 0 {
                                                Button {
                                                    Task {
                                                        listStatus.numVolumesRead -= 1
                                                        await controller.updateManga(index: index, id: item.id, listStatus: listStatus)
                                                    }
                                                } label: {
                                                    Label("-1 volume read", systemImage: "minus.circle")
                                                }
                                            }
                                        }
                                    }
                                    .swipeActions(edge: .trailing) {
                                        if settings.useSwipeActions && !controller.isLoading {
                                            if settings.mangaReadProgress == 0 {
                                                if var listStatus = item.listStatus, item.node.numChapters == nil || item.node.numChapters == 0 || listStatus.numChaptersRead < (item.node.numChapters ?? .max) {
                                                    Button {
                                                        Task {
                                                            listStatus.numChaptersRead += 1
                                                            await controller.updateManga(index: index, id: item.id, listStatus: listStatus)
                                                        }
                                                    } label: {
                                                        Label("+1 chapter read", systemImage: "plus.circle")
                                                    }
                                                }
                                            } else if var listStatus = item.listStatus, item.node.numVolumes == nil || item.node.numVolumes == 0 || listStatus.numVolumesRead < (item.node.numVolumes ?? .max) {
                                                Button {
                                                    Task {
                                                        listStatus.numVolumesRead += 1
                                                        await controller.updateManga(index: index, id: item.id, listStatus: listStatus)
                                                    }
                                                } label: {
                                                    Label("+1 volume read", systemImage: "plus.circle")
                                                }
                                            }
                                        }
                                    }
                            }
                        }
                        if controller.isMangaLoading {
                            LoadingList(length: 5)
                                .id(controller.mangaLoadId)
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            if networker.isSignedIn {
                VStack {
                    ZStack {
                        if controller.type == .anime {
                            animeList
                        } else if controller.type == .manga {
                            mangaList
                        }
                        if controller.isLoading {
                            LoadingView()
                        }
                    }
                }
                .refreshable {
                    isRefresh = true
                }
                .task(id: isRefresh) {
                    await controller.refresh(!controller.isItemsEmpty())
                    if isRefresh {
                        if controller.type == .anime {
                            await controller.refreshAnime(!controller.isItemsEmpty())
                        } else if controller.type == .manga {
                            await controller.refreshManga(!controller.isItemsEmpty())
                        }
                        isRefresh = false
                    }
                }
                .sheet(item: $selectedAnime) {
                    Task {
                        if let index = selectedAnimeIndex, let animeListStatus = animeListStatus {
                            if isAnimeDeleted || animeListStatus.status != controller.animeStatus {
                                controller.animeItems.remove(at: index)
                            } else {
                                controller.animeItems[index].listStatus = animeListStatus
                            }
                            isAnimeDeleted = false
                            selectedAnimeIndex = nil
                        }
                    }
                } content: { anime in
                    AnimeEditView(id: anime.id, listStatus: anime.listStatus, title: anime.node.title, enTitle: anime.node.alternativeTitles?.en, numEpisodes: anime.node.numEpisodes, imageUrl: anime.node.mainPicture?.large, isDeleted: $isAnimeDeleted, animeListStatus: $animeListStatus)
                        .presentationBackground {
                            if settings.translucentBackground {
                                ImageFrame(id: "anime\(anime.id)", imageUrl: anime.node.mainPicture?.large, imageSize: .background)
                            } else {
                                Color(.systemGray6)
                            }
                        }
                }
                .sheet(item: $selectedManga) {
                    Task {
                        if let index = selectedMangaIndex, let mangaListStatus = mangaListStatus {
                            if isMangaDeleted || mangaListStatus.status != controller.mangaStatus {
                                controller.mangaItems.remove(at: index)
                            } else {
                                controller.mangaItems[index].listStatus = mangaListStatus
                            }
                            isMangaDeleted = false
                            selectedMangaIndex = nil
                        }
                    }
                } content: { manga in
                    MangaEditView(id: manga.id, listStatus: manga.listStatus, title: manga.node.title, enTitle: manga.node.alternativeTitles?.en, numVolumes: manga.node.numVolumes, numChapters: manga.node.numChapters, imageUrl: manga.node.mainPicture?.large, isDeleted: $isMangaDeleted, mangaListStatus: $mangaListStatus)
                        .presentationBackground {
                            if settings.translucentBackground {
                                ImageFrame(id: "manga\(manga.id)", imageUrl: manga.node.mainPicture?.large, imageSize: .background)
                            } else {
                                Color(.systemGray6)
                            }
                        }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        filter
                            .disabled(controller.isAnimeLoading || controller.isMangaLoading)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        AnimeMangaToggle(type: $controller.type)
                    }
                }
                .navigationTitle(controller.type == .anime ? "My anime list" : "My manga list")
            } else {
                List {
                    SignInSections()
                }
                .navigationTitle("My list")
            }
        }
        .systemNotification(isActive: $controller.isEditError) {
            Label("Unable to save", systemImage: "exclamationmark.triangle.fill")
                .labelStyle(.iconTint(.red))
                .padding()
        }
        .onAppear {
            if !isInit {
                controller.animeStatus = settings.getAnimeStatus()
                controller.animeSort = settings.getAnimeSort()
                controller.mangaStatus = settings.getMangaStatus()
                controller.mangaSort = settings.getMangaSort()
                isInit = true
            }
        }
        .id(id)
        .task(id: id) {
            if let type = type {
                controller.type = type
            }
            type = nil
            if controller.type == .anime {
                if let animeStatus = animeStatus {
                    controller.animeStatus = animeStatus
                }
                animeStatus = nil
                if let animeSort = animeSort {
                    controller.animeSort = animeSort
                }
                animeSort = nil
            } else if controller.type == .manga {
                if let mangaStatus = mangaStatus {
                    controller.mangaStatus = mangaStatus
                }
                mangaStatus = nil
                if let mangaSort = mangaSort {
                    controller.mangaSort = mangaSort
                }
                mangaSort = nil
            }
        }
    }
}
