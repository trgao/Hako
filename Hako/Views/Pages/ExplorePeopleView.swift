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
            List {
                if controller.isLoading && controller.people.isEmpty {
                    LoadingList(length: 20)
                } else if controller.isLoadingError && controller.people.isEmpty {
                    ErrorView(refresh: controller.refresh)
                } else {
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
            }
            .disabled(controller.isLoading && controller.people.isEmpty)
            .refreshable {
                isRefresh = true
            }
            .task(id: isRefresh) {
                if controller.people.isEmpty || isRefresh {
                    await controller.refresh()
                    isRefresh = false
                }
            }
            if controller.isLoading && isRefresh {
                LoadingView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("People")
    }
}
