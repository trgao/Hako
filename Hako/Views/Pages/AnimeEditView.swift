//
//  AnimeEditView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/5/24.
//

import SwiftUI

struct AnimeEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var listStatus: AnimeListStatus
    @State private var isDeleteError = false
    @State private var isDeleting = false
    @State private var isEditError = false
    private let id: Int
    private let title: String
    private let numEpisodes: Int?
    private let imageUrl: String?
    let networker = NetworkManager.shared
    
    init(id: Int, listStatus: AnimeListStatus?, title: String, numEpisodes: Int?, imageUrl: String?) {
        self.id = id
        if let listStatus = listStatus {
            self.listStatus = listStatus
        } else {
            self.listStatus = AnimeListStatus(status: .planToWatch, score: 0, numEpisodesWatched: 0, updatedAt: nil)
        }
        self.title = title
        self.numEpisodes = numEpisodes
        self.imageUrl = imageUrl
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    Spacer()
                    Button {
                        Task {
                            do {
                                try await networker.editUserAnime(id: id, listStatus: listStatus)
                                dismiss()
                            } catch {
                                isEditError = true
                            }
                        }
                    } label: {
                        Text("Save")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding([.horizontal, .top], 20)
                PageList {
                    Section {
                        Picker("Status", selection: $listStatus.status) {
                            Text("Watching").tag(StatusEnum.watching as StatusEnum?)
                            Text("Completed").tag(StatusEnum.completed as StatusEnum?)
                            Text("On Hold").tag(StatusEnum.onHold as StatusEnum?)
                            Text("Dropped").tag(StatusEnum.dropped as StatusEnum?)
                            Text("Plan To Watch").tag(StatusEnum.planToWatch as StatusEnum?)
                        }
                        .pickerStyle(.menu)
                        .onChange(of: listStatus.status) { status in
                            if status == .watching && listStatus.startDate == nil {
                                listStatus.startDate = Date()
                            }
                            if status == .completed && listStatus.finishDate == nil {
                                listStatus.finishDate = Date()
                            }
                        }
                        Picker("Score", selection: $listStatus.score) {
                            Text("0 - Not Yet Scored").tag(0)
                            Text("1 - Appalling").tag(1)
                            Text("2 - Horrible").tag(2)
                            Text("3 - Very Bad").tag(3)
                            Text("4 - Bad").tag(4)
                            Text("5 - Average").tag(5)
                            Text("6 - Fine").tag(6)
                            Text("7 - Good").tag(7)
                            Text("8 - Very Good").tag(8)
                            Text("9 - Great").tag(9)
                            Text("10 - Masterpiece").tag(10)
                        }
                        .pickerStyle(.menu)
                        NumberSelector(num: $listStatus.numEpisodesWatched, title: "Episodes Watched", max: numEpisodes)
                    }
                    Section {
                        if listStatus.startDate != nil {
                            HStack {
                                DatePicker(
                                    "Start Date",
                                    selection: $listStatus.startDate ?? Date(),
                                    displayedComponents: [.date]
                                )
                                Button {
                                    listStatus.startDate = nil
                                } label: {
                                    Image(systemName: "xmark")
                                }
                            }
                        } else {
                            HStack {
                                Text("Start Date")
                                Spacer()
                                Button {
                                    listStatus.startDate = Date()
                                } label: {
                                    Text("Add start date")
                                }
                            }
                        }
                        if listStatus.finishDate != nil {
                            HStack {
                                DatePicker(
                                    "Finish Date",
                                    selection: $listStatus.finishDate ?? Date(),
                                    displayedComponents: [.date]
                                )
                                Button {
                                    listStatus.finishDate = nil
                                } label: {
                                    Image(systemName: "xmark")
                                }
                            }
                        } else {
                            HStack {
                                Text("Finish Date")
                                Spacer()
                                Button {
                                    listStatus.finishDate = Date()
                                } label: {
                                    Text("Add finish date")
                                }
                            }
                        }
                    }
                } header: {
                    ImageFrame(id: "anime\(id)", imageUrl: imageUrl, imageSize: .medium)
                    Text(title)
                        .bold()
                        .font(.system(size: 20))
                        .padding([.horizontal, .top], 10)
                        .multilineTextAlignment(.center)
                    if let updatedAt = listStatus.updatedAt?.toString() {
                        Text("Last updated at: \(updatedAt)")
                            .font(.system(size: 12))
                    }
                }
                .scrollContentBackground(.hidden)
                Button {
                    isDeleting = true
                } label: {
                    Label("Remove from list", systemImage: "trash")
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(.systemRed))
            }
        }
        .alert("Unable to delete", isPresented: $isDeleteError) {
            Button("OK", role: .cancel) {}
        }
        .alert("Unable to save", isPresented: $isEditError) {
            Button("OK", role: .cancel) {}
        }
        .confirmationDialog("Are you sure?", isPresented: $isDeleting) {
            Button("Confirm", role: .destructive) {
                Task {
                    do {
                        try await networker.deleteUserAnime(id: id)
                        dismiss()
                    } catch {
                        isDeleteError = true
                    }
                }
            }
        } message: {
            Text("This will remove this anime from your list")
        }
    }
}
