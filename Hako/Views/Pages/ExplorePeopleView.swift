//
//  ExplorePeopleView.swift
//  Hako
//
//  Created by Gao Tianrun on 7/1/26.
//

import SwiftUI

struct ExplorePeopleView: View {
    @StateObject private var controller = ExplorePeopleViewController()
    @State private var isRefresh = false
    
    var body: some View {
        ZStack {
            if controller.loadingState == .error && controller.people.isEmpty {
                ErrorView(refresh: controller.refresh)
            } else {
                List {
                    if controller.loadingState == .loading && controller.people.isEmpty {
                        LoadingList(length: 20)
                    } else {
                        ForEach(Array(controller.people.enumerated()), id: \.1.id) { index, person in
                            PersonListItem(person: person)
                                .onAppear {
                                    Task {
                                        await controller.loadMoreIfNeeded(index: index)
                                    }
                                }
                        }
                        if controller.loadingState == .paginating {
                            LoadingList(length: 5)
                        }
                    }
                }
                .disabled(controller.loadingState == .loading && controller.people.isEmpty)
                .refreshable {
                    isRefresh = true
                }
                .task(id: isRefresh) {
                    if controller.people.isEmpty || isRefresh {
                        await controller.refresh()
                        isRefresh = false
                    }
                }
                if isRefresh {
                    LoadingView()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("People")
    }
}
