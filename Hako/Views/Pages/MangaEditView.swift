//
//  AnimeEditView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/5/24.
//

import SwiftUI

struct MangaEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var listStatus: MangaListStatus
    @State private var isDeleteError = false
    @State private var isDeleting = false
    @State private var isEditError = false
    private let id: Int
    private let title: String
    private let numVolumes: Int?
    private let numChapters: Int?
    private let imageUrl: String?
    let networker = NetworkManager.shared
    
    init(id: Int, listStatus: MangaListStatus?, title: String, numVolumes: Int?, numChapters: Int?, imageUrl: String?) {
        self.id = id
        if let listStatus = listStatus {
            self.listStatus = listStatus
        } else {
            self.listStatus = MangaListStatus(status: .planToRead, score: 0, numVolumesRead: 0, numChaptersRead: 0, updatedAt: nil)
        }
        self.title = title
        self.numVolumes = numVolumes
        self.numChapters = numChapters
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
                                try await networker.editUserManga(id: id, listStatus: listStatus)
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
                            Text("Reading").tag(StatusEnum.reading as StatusEnum?)
                            Text("Completed").tag(StatusEnum.completed as StatusEnum?)
                            Text("On Hold").tag(StatusEnum.onHold as StatusEnum?)
                            Text("Dropped").tag(StatusEnum.dropped as StatusEnum?)
                            Text("Plan To Read").tag(StatusEnum.planToRead as StatusEnum?)
                        }
                        .pickerStyle(.menu)
                        .onChange(of: listStatus.status) { _, status in
                            if status == .reading && listStatus.startDate == nil {
                                listStatus.startDate = Date()
                            }
                            if status == .completed {
                                if listStatus.finishDate == nil {
                                    listStatus.finishDate = Date()
                                }
                                if let numVolumes = numVolumes, listStatus.numVolumesRead != numVolumes {
                                    listStatus.numVolumesRead = numVolumes
                                }
                                if let numChapters = numChapters, listStatus.numChaptersRead != numChapters {
                                    listStatus.numChaptersRead = numChapters
                                }
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
                        NumberSelector(num: $listStatus.numVolumesRead, title: "Volumes Read", max: numVolumes)
                        NumberSelector(num: $listStatus.numChaptersRead, title: "Chapters Read", max: numChapters)
                    }
                    Section {
                        if listStatus.startDate != nil {
                            DatePicker(
                                "Start Date",
                                selection: $listStatus.startDate ?? Date(),
                                displayedComponents: [.date]
                            )
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
                            DatePicker(
                                "Finish Date",
                                selection: $listStatus.finishDate ?? Date(),
                                displayedComponents: [.date]
                            )
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
                    ImageFrame(id: "manga\(id)", imageUrl: imageUrl, imageSize: .medium)
                        .padding([.top], 10)
                    Text(title)
                        .bold()
                        .font(.system(size: 20))
                        .padding(.top, 10)
                        .padding(.horizontal, 20)
                        .multilineTextAlignment(.center)
                        .textCase(nil)
                    if let updatedAt = listStatus.updatedAt?.toString() {
                        Text("Last updated at: \(updatedAt)")
                            .font(.system(size: 12))
                            .textCase(nil)
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
                        try await networker.deleteUserManga(id: id)
                        dismiss()
                    } catch {
                        isDeleteError = true
                    }
                }
            }
        } message: {
            Text("This will remove this manga from your list")
        }
    }
}
