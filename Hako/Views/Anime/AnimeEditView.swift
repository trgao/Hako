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
    @State private var listStatus: MyListStatus
    @State private var initialData: MyListStatus
    @State private var isLoading = false
    @State private var isConfirmDeleting = false
    @State private var isDeleting = false
    @State private var isDeleteError = false
    @State private var isEditError = false
    @State private var isDiscardingChanges = false
    private let anime: Anime
    private let networker = NetworkManager.shared

    private var viewTitle: String {
        settings.getTitle(romaji: anime.title, english: anime.alternativeTitles?.en, native: anime.alternativeTitles?.ja)
    }

    private var committed: MyListStatus? {
        networker.getAnimeListStatus(anime.id).value
    }

    private var hasChanges: Bool {
        listStatus != initialData
    }

    init(anime: Anime) {
        self.anime = anime
        let start = NetworkManager.shared.getAnimeListStatus(anime.id).value ?? MyListStatus.animeDefault
        self._listStatus = State(initialValue: start)
        self._initialData = State(initialValue: start)
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
                                if let numEpisodes = anime.numEpisodes, numEpisodes > 0, listStatus.numEpisodesWatched != numEpisodes {
                                    listStatus.numEpisodesWatched = numEpisodes
                                }
                            }
                        }
                    PickerRow(title: "Score", selection: $listStatus.score, labels: Constants.scoreLabels)
                    NumberSelector(title: "Episodes watched", num: $listStatus.numEpisodesWatched, max: anime.numEpisodes)
                        .onChange(of: listStatus.numEpisodesWatched) { prev, cur in
                            if listStatus.status == .planToWatch && prev == 0 && cur > 0 {
                                listStatus.status = .watching
                            }
                            if let numEpisodes = anime.numEpisodes, cur == numEpisodes && numEpisodes > 0 {
                                listStatus.status = .completed
                            }
                        }
                }
                Section {
                    DatePickerRow(title: "Start date", date: $listStatus.startDate)
                    DatePickerRow(title: "Finish date", date: $listStatus.finishDate)
                }
                if initialData.updatedAt != nil {
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
                                    try await networker.deleteUserAnime(id: anime.id)
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
                ImageFrame(id: "anime\(anime.id)", imageUrl: anime.mainPicture?.large, imageSize: .medium)
            } subtitle: {
                VStack {
                    Text(viewTitle)
                        .bold()
                        .font(.title3)
                        .multilineTextAlignment(.center)
                    if let updatedAt = committed?.updatedAt?.toFullString() {
                        Text("Last updated at: \(updatedAt)")
                            .font(.caption)
                            .opacity(0.7)
                    } else {
                        Text("Not added to list")
                            .font(.caption)
                            .opacity(0.7)
                    }
                    if hasChanges {
                        Text("Unsaved changes")
                            .font(.caption)
                            .opacity(0.7)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if !hasChanges {
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
                    Button {
                        Task {
                            isLoading = true
                            do {
                                try await networker.editUserAnime(id: anime.id, listStatus: listStatus)
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
                    .prominentButtonStyle()
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
        .checkSwipeDismissChanges(isDisabled: hasChanges, isLoading: isLoading, isDiscardingChanges: $isDiscardingChanges)
    }
}
