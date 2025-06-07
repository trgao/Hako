//
//  AnimeEditView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/5/24.
//

import SwiftUI

struct MangaEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding private var isDeleted: Bool
    @Binding private var mangaStatus: MangaListStatus?
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
        "0 - Not yet scored",
        "1 - Appalling",
        "2 - Horrible",
        "3 - Very bad",
        "4 - Bad",
        "5 - Average",
        "6 - Fine",
        "7 - Good",
        "8 - Very good",
        "9 - Great",
        "10 - Masterpiece"
    ]
    let networker = NetworkManager.shared
    
    init(id: Int, listStatus: MangaListStatus?, title: String, numVolumes: Int?, numChapters: Int?, imageUrl: String?, isDeleted: Binding<Bool>? = nil, mangaStatus: Binding<MangaListStatus?>? = nil) {
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
        if let isDeleted = isDeleted {
            self._isDeleted = isDeleted
        } else {
            self._isDeleted = .constant(false)
        }
        if let mangaStatus = mangaStatus {
            self._mangaStatus = mangaStatus
        } else {
            self._mangaStatus = .constant(nil)
        }
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
                                    mangaStatus = listStatus
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
                            NumberSelector(num: $listStatus.numVolumesRead, title: "Volumes read", max: numVolumes)
                                .onChange(of: listStatus.numVolumesRead) { prev, cur in
                                    if listStatus.status == .planToRead && prev == 0 && cur > 0 {
                                        listStatus.status = .reading
                                    }
                                }
                            NumberSelector(num: $listStatus.numChaptersRead, title: "Chapters read", max: numChapters)
                                .onChange(of: listStatus.numChaptersRead) { prev, cur in
                                    if listStatus.status == .planToRead && prev == 0 && cur > 0 {
                                        listStatus.status = .reading
                                    }
                                }
                        }
                        Section {
                            if listStatus.startDate != nil {
                                HStack {
                                    DatePicker(
                                        "Start date",
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
                                    Text("Start date")
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
                                        "Finish date",
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
                                    Text("Finish date")
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
        .onAppear {
            mangaStatus = listStatus
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
                        isDeleted = true
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
        .scrollDismissesKeyboard(.immediately)
    }
}

private func statusToIndex(_ status: StatusEnum?) -> Int {
    if status == .reading {
        return 0
    } else if status == .completed {
        return 1
    } else if status == .onHold {
        return 2
    } else if status == .dropped {
        return 3
    } else {
        return 4
    }
}

struct MangaStatusPickerRow: View {
    @State private var selected: Int
    @Binding var selection: StatusEnum?
    private let labels = ["Reading", "Completed", "On hold", "Dropped", "Plan to read"]
    private let mappings: [StatusEnum?] = [.reading, .completed, .onHold, .dropped, .planToRead]
    
    init(selection: Binding<StatusEnum?>) {
        self._selection = selection
        self.selected = statusToIndex(selection.wrappedValue)
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
        } label: {
            HStack {
                Text(labels[selected])
                Image(systemName: "chevron.down")
                    .font(.system(size: 13))
            }
        }
        .onChange(of: selection) { _, cur in
            selected = statusToIndex(cur)
        }
    }
}
