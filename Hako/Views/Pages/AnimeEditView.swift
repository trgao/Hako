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
                        AnimeStatusPickerRow(selection: $listStatus.status)
                        .onChange(of: listStatus.status) { _, status in
                            if status == .watching && listStatus.startDate == nil {
                                listStatus.startDate = Date()
                            }
                            if status == .completed {
                                if listStatus.finishDate == nil {
                                    listStatus.finishDate = Date()
                                }
                                if let numEpisodes = numEpisodes, listStatus.numEpisodesWatched != numEpisodes {
                                    listStatus.numEpisodesWatched = numEpisodes
                                }
                            }
                        }
                        PickerRow(title: "Score", selection: $listStatus.score, labels: scoreLabels)
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
                    Button {
                        isDeleting = true
                    } label: {
                        Label("Remove from list", systemImage: "trash")
                    }
                    .foregroundStyle(Color(.systemRed))
                } header: {
                    ImageFrame(id: "anime\(id)", imageUrl: imageUrl, imageSize: .medium)
                    Text(title)
                        .bold()
                        .font(.system(size: 20))
                        .padding(.top, 10)
                        .padding(.horizontal, 20)
                        .multilineTextAlignment(.center)
                    if let updatedAt = listStatus.updatedAt?.toString() {
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

struct AnimeStatusPickerRow: View {
    @State private var selected: Int
    @Binding var selection: StatusEnum?
    private let labels = ["Watching", "Completed", "On Hold", "Dropped", "Plan To Watch"]
    private let mappings: [StatusEnum?] = [.watching, .completed, .onHold, .dropped, .planToWatch]
    
    init(selection: Binding<StatusEnum?>) {
        self._selection = selection
        if selection.wrappedValue == .watching {
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

