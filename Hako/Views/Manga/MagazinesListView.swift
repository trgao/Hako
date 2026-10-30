//
//  MagazinesListView.swift
//  Hako
//
//  Created by Gao Tianrun on 9/1/26.
//

import SwiftUI

struct MagazinesListView: View {
    @StateObject private var controller = MagazinesListViewController()
    @State private var isRefresh = false

    var body: some View {
        ZStack {
            if controller.loadingState == .error && controller.magazines.isEmpty {
                ErrorView(refresh: controller.refresh)
                    .padding(.vertical, 50)
            } else {
                List {
                    if controller.loadingState == .loading && controller.magazines.isEmpty {
                        LoadingList(showImage: false)
                    } else {
                        ForEach(controller.magazines) { magazine in
                            if let name = magazine.name {
                                NavigationLink(value: Route.groupDetail(GroupDetail(id: magazine.id, name: name, type: .manga, group: "magazines"))) {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(name).bold()
                                        if let count = magazine.count {
                                            Text("\(count) manga")
                                                .opacity(0.7)
                                                .font(.footnote)
                                        }
                                    }
                                }
                                .onAppear {
                                    Task {
                                        if magazine.id == controller.magazines.last?.id {
                                            await controller.loadMore()
                                        }
                                    }
                                }
                            }
                        }
                        if controller.loadingState == .paginating {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                        }
                    }
                }
                .disabled(controller.loadingState == .loading && controller.magazines.isEmpty)
                .refreshable {
                    isRefresh = true
                }
                .task(id: isRefresh) {
                    if controller.magazines.isEmpty || isRefresh {
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
        .navigationTitle("Magazines")
    }
}
