//
//  CompaniesListView.swift
//  Hako
//
//  Created by Gao Tianrun on 9/1/26.
//

import SwiftUI

struct CompaniesListView: View {
    @StateObject private var controller = CompaniesListViewController()
    @State private var isRefresh = false
    
    var body: some View {
        ZStack {
            if controller.loadingState == .error && controller.companies.isEmpty {
                ErrorView(refresh: controller.refresh)
                    .padding(.vertical, 50)
            } else {
                List {
                    if controller.loadingState == .loading && controller.companies.isEmpty {
                        LoadingList(length: 20, showImage: false)
                    } else {
                        ForEach(controller.companies) { company in
                            if let title = company.titles?.first(where: { $0.type == "Default" })?.title {
                                NavigationLink {
                                    GroupDetailsView(title: title, group: "producers", id: company.id, type: .anime)
                                } label: {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(title).bold()
                                        Group {
                                            if let established = company.established {
                                                Text("Established on \(established.toString())")
                                            }
                                            if let favorites = company.favorites {
                                                Text("\(favorites) favourites")
                                            }
                                            if let count = company.count {
                                                Text("\(count) anime")
                                            }
                                        }
                                        .opacity(0.7)
                                        .font(.footnote)
                                    }
                                }
                                .onAppear {
                                    Task {
                                        if company.id == controller.companies.last?.id {
                                            await controller.loadMore()
                                        }
                                    }
                                }
                            }
                        }
                        if controller.loadingState == .paginating {
                            LoadingList(length: 5, showImage: false)
                        }
                    }
                }
                .disabled(controller.loadingState == .loading && controller.companies.isEmpty)
                .refreshable {
                    isRefresh = true
                }
                .task(id: isRefresh) {
                    if controller.companies.isEmpty || isRefresh {
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
        .navigationTitle("Companies")
    }
}
