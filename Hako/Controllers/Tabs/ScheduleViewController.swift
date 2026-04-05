//
//  ScheduleViewController.swift
//  Hako
//
//  Created by Gao Tianrun on 3/4/26.
//

import Foundation

@MainActor
class ScheduleViewController: ObservableObject {
    @Published var animeItems: [AiringSchedule] = []
    @Published var schedule: [String: [AiringSchedule]] = [:]
    @Published var loadingState: LoadingEnum = .loading
    private var currentAnimePage = 1
    private var canLoadMoreAnimePages = true
    private let networker = NetworkManager.shared
    
    // Check if the current anime list is loading
    func isLoading() -> Bool {
        return loadingState == .loading || loadingState == .paginating
    }
    
    func refresh() async {
        loadingState = .loading
        currentAnimePage = 1
        canLoadMoreAnimePages = true
        
        do {
            let animeList = try await networker.getAnimeScheduleList(page: currentAnimePage)
            currentAnimePage = 2
            canLoadMoreAnimePages = !(animeList.isEmpty)
            var newSchedule: [String: [AiringSchedule]] = [:]
            animeList
                .filter { $0.media.idMal != nil }
                .forEach { item in
                    let day = Date(timeIntervalSince1970: TimeInterval(item.airingAt)).formatted(.dateTime.weekday(.wide).month(.wide).day())
                    newSchedule[day, default: []].append(item)
                }
            schedule = newSchedule
            animeItems = animeList
            loadingState = .idle
        } catch {
            if !Task.isCancelled && !(error is CancellationError) {
               loadingState = .error
            }
        }
    }
    
    // Load more of the current anime list
    private func loadMore() async {
        // only load more when it is not loading, page is not empty and there are more pages to be loaded
        guard loadingState == .idle && !schedule.isEmpty && canLoadMoreAnimePages else {
            return
        }
        
        loadingState = .paginating
        if let animeList = try? await networker.getAnimeScheduleList(page: currentAnimePage) {
            currentAnimePage += 1
            canLoadMoreAnimePages = !(animeList.isEmpty)
            animeList
                .filter { $0.media.idMal != nil }
                .forEach { item in
                    let day = Date(timeIntervalSince1970: TimeInterval(item.airingAt)).formatted(.dateTime.weekday(.wide).month(.wide).day())
                    schedule[day, default: []].append(item)
                }
            animeItems.append(contentsOf: animeList)
        }
        loadingState = .idle
    }
    
    // Load more anime when reaching the 4th last anime in list
    func loadMoreIfNeeded(id: String) async {
        if id == animeItems[animeItems.endIndex - 5].id {
            await loadMore()
        }
    }
}
