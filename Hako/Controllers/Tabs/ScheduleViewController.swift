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
    private var currentPage = 1
    private var canLoadMorePages = true
    private let networker = NetworkManager.shared
    
    // Check if the current anime list is loading
    func isLoading() -> Bool {
        return loadingState == .loading || loadingState == .paginating
    }
    
    func refresh() async {
        loadingState = .loading
        currentPage = 1
        canLoadMorePages = true
        
        do {
            let animeList = try await networker.getAnimeScheduleList(page: currentPage).filter { $0.media.idMal != nil && $0.media.isAdult == false }
            currentPage = 2
            canLoadMorePages = !(animeList.isEmpty)
            var newSchedule: [String: [AiringSchedule]] = [:]
            animeList.forEach { item in
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
        guard loadingState == .idle && !schedule.isEmpty && canLoadMorePages else {
            return
        }
        
        loadingState = .paginating
        if let animeList = try? await networker.getAnimeScheduleList(page: currentPage).filter({ $0.media.idMal != nil && $0.media.isAdult == false }) {
            currentPage += 1
            canLoadMorePages = !(animeList.isEmpty)
            animeList.forEach { item in
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
