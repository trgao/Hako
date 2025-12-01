//
//  AnimeEditView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/5/24.
//

import SwiftUI
import SystemNotification

struct AnimeEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: SettingsManager
    @Binding private var isDeleted: Bool
    @Binding private var animeListStatus: MyListStatus?
    @State private var listStatus: MyListStatus
    @State private var isDeleteError = false
    @State private var isDeleting = false
    @State private var isEditError = false
    @State private var isDiscardingChanges = false
    @State private var isLoading = false
    private let id: Int
    private let initialData: MyListStatus
    private let title: String?
    private let enTitle: String?
    private let numEpisodes: Int?
    private let imageUrl: String?
    let networker = NetworkManager.shared
    
    init(id: Int, listStatus: MyListStatus?, title: String?, enTitle: String?, numEpisodes: Int?, imageUrl: String?, isDeleted: Binding<Bool>? = nil, animeListStatus: Binding<MyListStatus?>? = nil) {
        self.id = id
        var initialData = MyListStatus(status: .planToWatch)
        if let listStatus = listStatus {
            initialData = listStatus
        }
        self.initialData = initialData
        self.listStatus = initialData
        self.title = title
        self.enTitle = enTitle
        self.numEpisodes = numEpisodes
        self.imageUrl = imageUrl
        if let isDeleted = isDeleted {
            self._isDeleted = isDeleted
        } else {
            self._isDeleted = .constant(false)
        }
        if let animeListStatus = animeListStatus {
            self._animeListStatus = animeListStatus
        } else {
            self._animeListStatus = .constant(nil)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    PageList {
                        Section {
                            AnimeStatusPickerRow(selection: $listStatus.status)
                                .onChange(of: listStatus.status) { _, status in
                                    if status == .watching && listStatus.startDate == nil && settings.autofillStartDate {
                                        listStatus.startDate = Date()
                                    }
                                    if status == .completed {
                                        if listStatus.finishDate == nil && settings.autofillEndDate {
                                            listStatus.finishDate = Date()
                                        }
                                        if let numEpisodes = numEpisodes, listStatus.numEpisodesWatched != numEpisodes && numEpisodes > 0 {
                                            listStatus.numEpisodesWatched = numEpisodes
                                        }
                                    }
                                }
                            PickerRow(title: "Score", selection: $listStatus.score, labels: Constants.scoreLabels)
                            NumberSelector(num: $listStatus.numEpisodesWatched, title: "Episodes watched", max: numEpisodes)
                                .onChange(of: listStatus.numEpisodesWatched) { prev, cur in
                                    if listStatus.status == .planToWatch && prev == 0 && cur > 0 {
                                        listStatus.status = .watching
                                    }
                                    if let numEpisodes = numEpisodes, cur == numEpisodes && numEpisodes > 0 {
                                        listStatus.status = .completed
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
                        if let _ = listStatus.updatedAt {
                            Button {
                                isDeleting = true
                            } label: {
                                Label("Remove from list", systemImage: "trash")
                            }
                            .foregroundStyle(Color(.systemRed))
                            .confirmationDialog("Are you sure?", isPresented: $isDeleting) {
                                Button("Confirm", role: .destructive) {
                                    Task {
                                        isLoading = true
                                        do {
                                            try await networker.deleteUserAnime(id: id)
                                            isDeleted = true
                                            dismiss()
                                        } catch {
                                            isDeleteError = true
                                        }
                                        isLoading = false
                                    }
                                }
                            } message: {
                                Text("This will remove this anime from your list")
                            }
                        }
                    } photo: {
                        ImageFrame(id: "anime\(id)", imageUrl: imageUrl, imageSize: .medium)
                    } subtitle: {
                        VStack {
                            if let title = enTitle, !title.isEmpty && settings.preferredTitleLanguage == 1 {
                                Text(title)
                                    .bold()
                                    .font(.system(size: 20))
                                    .multilineTextAlignment(.center)
                            } else {
                                Text(title ?? "")
                                    .bold()
                                    .font(.system(size: 20))
                                    .multilineTextAlignment(.center)
                            }
                            if let updatedAt = listStatus.updatedAt?.toFullString() {
                                Text("Last updated at: \(updatedAt)")
                                    .font(.system(size: 12))
                                    .opacity(0.7)
                            } else {
                                Text("Not added to list")
                                    .font(.system(size: 12))
                                    .opacity(0.7)
                            }
                            if listStatus != initialData {
                                Text("Unsaved changes")
                                    .font(.system(size: 12))
                                    .opacity(0.7)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .scrollBounceBehavior(.basedOnSize)
                }
                if isLoading {
                    LoadingView()
                }
            }
            .onAppear {
                animeListStatus = listStatus
            }
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if listStatus == initialData {
                            dismiss()
                        } else {
                            isDiscardingChanges = true
                        }
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .confirmationDialog("Are you sure?", isPresented: $isDiscardingChanges) {
                        Button("Discard", role: .destructive) {
                            dismiss()
                        }
                    } message: {
                        Text("Are you sure you want to discard changes?")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    let button = Button {
                        Task {
                            isLoading = true
                            do {
                                try await networker.editUserAnime(id: id, listStatus: listStatus)
                                animeListStatus = listStatus
                                dismiss()
                            } catch {
                                isEditError = true
                            }
                            isLoading = false
                        }
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    if #available (iOS 26.0, *) {
                        button.buttonStyle(.glassProminent)
                    } else {
                        button.buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        .systemNotification(isActive: $isDeleteError) {
            Label("Unable to delete", systemImage: "exclamationmark.triangle.fill")
                .labelStyle(.iconTint(.red))
                .padding()
        }
        .systemNotification(isActive: $isEditError) {
            Label("Unable to save", systemImage: "exclamationmark.triangle.fill")
                .labelStyle(.iconTint(.red))
                .padding()
        }
        .checkSwipeDismissChanges(listStatus != initialData, isDiscardingChanges: $isDiscardingChanges)
    }
}

private func statusToIndex(_ status: StatusEnum?) -> Int {
    if status == .watching {
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

struct AnimeStatusPickerRow: View {
    @State private var selected: Int
    @Binding var selection: StatusEnum?
    private let labels = ["Watching", "Completed", "On hold", "Dropped", "Plan to watch"]
    private let mappings: [StatusEnum?] = [.watching, .completed, .onHold, .dropped, .planToWatch]
    
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

