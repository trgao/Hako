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
            if controller.isLoading && controller.people.isEmpty {
                List {
                    LoadingList(length: 20)
                }
                .disabled(true)
            } else {
                if controller.isLoadingError && controller.people.isEmpty {
                    ErrorView(refresh: controller.refresh)
                } else {
                    List {
                        ForEach(Array(controller.people.enumerated()), id: \.1.id) { index, person in
                            PersonListItem(person: person)
                                .onAppear {
                                    Task {
                                        await controller.loadMoreIfNeeded(index: index)
                                    }
                                }
                        }
                        if controller.isLoading {
                            LoadingList(length: 5)
                        }
                    }
                    .refreshable {
                        isRefresh = true
                    }
                }
                if controller.isLoading && isRefresh {
                    LoadingView()
                }
            }
        }
        .task(id: isRefresh) {
            if controller.people.isEmpty || isRefresh {
                await controller.refresh()
                isRefresh = false
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("People")
    }
}
