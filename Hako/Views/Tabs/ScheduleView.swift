//
//  ScheduleView.swift
//  Hako
//
//  Created by Gao Tianrun on 3/4/26.
//

import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller = ScheduleViewController()
    @State private var isRefresh = false
    private var days: [String] = []
    private let isTab: Bool
    private var airingNextId: String? {
        controller.animeItems.first(where: { $0.airingAt >= Int(Date().timeIntervalSince1970) })?.id
    }
    
    init(isTab: Bool = false) {
        self.isTab = isTab
        for i in 0...6 {
            days.append(Date().addingTimeInterval(TimeInterval(i * 86400)).formatted(.dateTime.weekday(.wide).month(.wide).day()))
        }
    }
    
    @ViewBuilder private func DaySchedule(_ index: Int, _ width: CGFloat) -> some View {
        let day = days[index]
        if let items = controller.schedule[day] {
            // To make it appear like a section title, SwiftUI section is buggy with LazyVGrid
            Group {
                let numberOfColumns = max(1, Int((width - 5) / 455))
                let prevCount = index == 0 ? 0 : (controller.schedule[days[index - 1]]?.count ?? 0)
                ForEach(0..<((numberOfColumns - prevCount % numberOfColumns) % numberOfColumns), id: \.self) { id in
                    Color.clear.id("frontbuffer\(day)\(id)")
                }
                HStack(spacing: 20) {
                    Text(day)
                        .bold()
                        .font(.title2)
                    if index == 0 {
                        TagItem(text: "Today")
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                ForEach(0..<(numberOfColumns - 1), id: \.self) { id in
                    Color.clear.id("endbuffer\(day)\(id)")
                }
            }
            ForEach(items) { item in
                AiringScheduleItem(item: item, isAiringNext: item.id == airingNextId)
                    .id(item.id)
                    .frame(maxWidth: .infinity)
                    .onAppear {
                        Task {
                            await controller.loadMoreIfNeeded(id: item.id)
                        }
                    }
            }
        }
    }
    
    private var nothingFoundView: some View {
        VStack {
            Image(systemName: "calendar.badge.clock")
                .resizable()
                .frame(width: 45, height: 40)
            Text("Nothing found")
                .bold()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    private var content: some View {
        ZStack {
            GeometryReader { geometry in
                if controller.animeItems.isEmpty {
                    if controller.loadingState == .loading {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: min(geometry.size.width - 20, 450)), spacing: 10, alignment: .top)]) {
                            ForEach(0..<30) { _ in
                                PlaceholderAiringSchedule()
                            }
                        }
                        .padding(10)
                    } else if controller.loadingState == .error {
                        ErrorView(refresh: { await controller.refresh() })
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    } else if controller.loadingState == .idle {
                        nothingFoundView
                    }
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: min(geometry.size.width - 20, 450)), spacing: 10, alignment: .top)]) {
                                // Manually written to prevent LazyVGrid scroll from jumping when using ForEach on dictionary
                                DaySchedule(0, geometry.size.width)
                                DaySchedule(1, geometry.size.width)
                                DaySchedule(2, geometry.size.width)
                                DaySchedule(3, geometry.size.width)
                                DaySchedule(4, geometry.size.width)
                                DaySchedule(5, geometry.size.width)
                                DaySchedule(6, geometry.size.width)
                            }
                            .padding(10)
                        }
                        .toolbar {
                            if let id = airingNextId {
                                Button {
                                    proxy.scrollTo(id, anchor: .top)
                                } label: {
                                    Label("Next", systemImage: "forward.fill")
                                        .labelStyle(.iconOnly)
                                }
                            }
                        }
                    }
                }
            }
            if isRefresh || controller.loadingState == .paginating {
                LoadingView()
            }
        }
        .navigationTitle("Weekly schedule")
        .refreshable {
            isRefresh = true
        }
        .task(id: isRefresh) {
            if controller.schedule.isEmpty || isRefresh {
                await controller.refresh()
                isRefresh = false
            }
        }
    }
    
    var body: some View {
        if isTab {
            NavigationStack {
                content
            }
        } else {
            content
        }
    }
}

