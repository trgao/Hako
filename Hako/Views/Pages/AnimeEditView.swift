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
    @State private var isLoading = false
    @State private var isConfirmDeleting = false
    @State private var isDeleting = false
    @State private var isDeleteError = false
    @State private var isEditError = false
    @State private var isDiscardingChanges = false
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
    
    private var confirmButton: some View {
        Button {
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
            if isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Image(systemName: "checkmark")
                    .foregroundStyle(.white)
            }
        }
        .disabled(isLoading || isDeleting)
    }
    
    var body: some View {
        NavigationStack {
            PageList {
                Section {
                    StatusPickerRow(selection: $listStatus.status, type: .anime)
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
                    NumberSelector(title: "Episodes watched", num: $listStatus.numEpisodesWatched, max: numEpisodes)
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
                    DatePickerRow(title: "Start date", date: $listStatus.startDate)
                    DatePickerRow(title: "Finish date", date: $listStatus.finishDate)
                }
                if let _ = listStatus.updatedAt {
                    Button {
                        isConfirmDeleting = true
                    } label: {
                        Group {
                            if isDeleting {
                                ProgressView().tint(.red)
                            } else {
                                Label("Remove from list", systemImage: "trash")
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(isLoading || isDeleting)
                    .foregroundStyle(.red)
                    .confirmationDialog("Are you sure?", isPresented: $isConfirmDeleting) {
                        Button("Confirm", role: .destructive) {
                            Task {
                                isDeleting = true
                                do {
                                    try await networker.deleteUserAnime(id: id)
                                    isDeleted = true
                                    dismiss()
                                } catch {
                                    isDeleteError = true
                                }
                                isDeleting = false
                            }
                        }
                        .disabled(isLoading || isDeleting)
                    } message: {
                        Text("This will remove the anime from your list")
                    }
                }
            } photo: {
                ImageFrame(id: "anime\(id)", imageUrl: imageUrl, imageSize: .medium)
            } subtitle: {
                VStack {
                    if let title = enTitle, !title.isEmpty && settings.preferredTitleLanguage == 1 {
                        Text(title)
                            .bold()
                            .font(.title3)
                            .multilineTextAlignment(.center)
                    } else {
                        Text(title ?? "")
                            .bold()
                            .font(.title3)
                            .multilineTextAlignment(.center)
                    }
                    if let updatedAt = listStatus.updatedAt?.toFullString() {
                        Text("Last updated at: \(updatedAt)")
                            .font(.caption)
                            .opacity(0.7)
                    } else {
                        Text("Not added to list")
                            .font(.caption)
                            .opacity(0.7)
                    }
                    if listStatus != initialData {
                        Text("Unsaved changes")
                            .font(.caption)
                            .opacity(0.7)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .scrollBounceBehavior(.basedOnSize)
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
                    .disabled(isLoading || isDeleting)
                    .confirmationDialog("Are you sure?", isPresented: $isDiscardingChanges) {
                        Button("Discard", role: .destructive) {
                            dismiss()
                        }
                    } message: {
                        Text("Are you sure you want to discard changes?")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if #available (iOS 26.0, *) {
                        confirmButton.buttonStyle(.glassProminent)
                    } else {
                        confirmButton.buttonStyle(.borderedProminent)
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
        .checkSwipeDismissChanges(isDisabled: listStatus != initialData, isLoading: isLoading, isDiscardingChanges: $isDiscardingChanges)
    }
}
