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
    @State private var isLoading = false
    private let id: Int
    private let title: String
    private let numVolumes: Int?
    private let numChapters: Int?
    private let imageUrl: String?
    private let scoreLabels = [
        "0 - Not Yet Scored",
        "1 - Appalling",
        "2 - Horrible",
        "3 - Very Bad",
        "4 - Bad",
        "5 - Average",
        "6 - Fine",
        "7 - Good",
        "8 - Very Good",
        "9 - Great",
        "10 - Masterpiece"
    ]
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
            ZStack {
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
                                isLoading = true
                                do {
                                    try await networker.editUserManga(id: id, listStatus: listStatus)
                                    dismiss()
                                } catch {
                                    isEditError = true
                                }
                                isLoading = false
                            }
                        } label: {
                            Text("Save")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding([.horizontal, .top], 20)
                    PageList {
                        Section {
                            MangaStatusPickerRow(selection: $listStatus.status)
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
                            PickerRow(title: "Score", selection: $listStatus.score, labels: scoreLabels)
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
                        Button {
                            isDeleting = true
                        } label: {
                            Label("Remove from list", systemImage: "trash")
                        }
                        .foregroundStyle(Color(.systemRed))
                    } header: {
                        ImageFrame(id: "manga\(id)", imageUrl: imageUrl, imageSize: .medium)
                            .padding([.top], 10)
                        Text(title)
                            .bold()
                            .font(.system(size: 20))
                            .padding(.top, 10)
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)
                        if let updatedAt = listStatus.updatedAt?.toFullString() {
                            Text("Last updated at: \(updatedAt)")
                                .font(.system(size: 12))
                                .opacity(0.7)
                        } else {
                            Text("Not added to list")
                                .font(.system(size: 12))
                                .opacity(0.7)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
                if isLoading {
                    LoadingView()
                }
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
                    isLoading = true
                    do {
                        try await networker.deleteUserManga(id: id)
                        dismiss()
                    } catch {
                        isDeleteError = true
                    }
                    isLoading = false
                }
            }
        } message: {
            Text("This will remove this manga from your list")
        }
    }
}

struct MangaStatusPickerRow: View {
    @State private var selected: Int
    @Binding var selection: StatusEnum?
    private let labels = ["Reading", "Completed", "On Hold", "Dropped", "Plan To Read"]
    private let mappings: [StatusEnum?] = [.reading, .completed, .onHold, .dropped, .planToRead]
    
    init(selection: Binding<StatusEnum?>) {
        self._selection = selection
        if selection.wrappedValue == .reading {
            self.selected = 0
        } else if selection.wrappedValue == .completed {
            self.selected = 1
        } else if selection.wrappedValue == .onHold {
            self.selected = 2
        } else if selection.wrappedValue == .dropped {
            self.selected = 3
        } else {
            self.selected = 4
        }
    }
    
    var body: some View {
        HStack {
            Text("Status")
                .foregroundColor(.primary)
            Spacer()
            menu
        }
    }
    
    var menu: some View {
        Menu {
            ForEach(labels.indices, id: \.self) { index in
                if !labels[index].isEmpty {
                    Button {
                        selected = index
                        selection = mappings[index]
                    } label: {
                        if selected == index {
                            HStack {
                                Image(systemName: "checkmark")
                                Text(labels[index])
                            }
                        } else {
                            Text(labels[index])
                        }
                    }
                }
            }
        } label: {
            Text(labels[selected])
        }
    }
}
