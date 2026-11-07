//
//  MangaEditView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/5/24.
//

import SwiftUI
import SystemNotification

struct MangaEditView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: SettingsManager
    @State private var listStatus: MyListStatus
    @State private var initialData: MyListStatus
    @State private var isLoading = false
    @State private var isConfirmingDelete = false
    @State private var isDeleting = false
    @State private var isDeleteError = false
    @State private var isEditError = false
    @State private var isDiscardingChanges = false
    private let manga: Manga
    private let networker = NetworkManager.shared

    private var viewTitle: String {
        settings.getTitle(romaji: manga.title, english: manga.alternativeTitles?.en, native: manga.alternativeTitles?.ja)
    }

    private var committed: MyListStatus? {
        networker.getMangaListStatus(manga.id).value
    }

    private var hasChanges: Bool {
        listStatus != initialData
    }

    init(manga: Manga) {
        self.manga = manga
        let start = NetworkManager.shared.getMangaListStatus(manga.id).value ?? MyListStatus.mangaDefault
        self._listStatus = State(initialValue: start)
        self._initialData = State(initialValue: start)
    }

    var body: some View {
        NavigationStack {
            PageList {
                Section {
                    StatusPickerRow(selection: $listStatus.status, type: .manga)
                        .onChange(of: listStatus.status) { _, status in
                            if status == .reading && listStatus.startDate == nil && settings.autofillStartDate {
                                listStatus.startDate = Date()
                            }
                            if status == .completed {
                                if listStatus.finishDate == nil && settings.autofillEndDate {
                                    listStatus.finishDate = Date()
                                }
                                if let numVolumes = manga.numVolumes, listStatus.numVolumesRead != numVolumes, numVolumes > 0 {
                                    listStatus.numVolumesRead = numVolumes
                                }
                                if let numChapters = manga.numChapters, listStatus.numChaptersRead != numChapters, numChapters > 0 {
                                    listStatus.numChaptersRead = numChapters
                                }
                            }
                        }
                    PickerRow(title: "Score", selection: $listStatus.score, labels: Constants.scoreLabels)
                    NumberSelector(title: "Volumes read", num: $listStatus.numVolumesRead, max: manga.numVolumes)
                        .onChange(of: listStatus.numVolumesRead) { prev, cur in
                            if listStatus.status == .planToRead && prev == 0 && cur > 0 {
                                listStatus.status = .reading
                            }
                            if settings.mangaReadProgress == 1, let numVolumes = manga.numVolumes, cur == numVolumes && numVolumes > 0 {
                                listStatus.status = .completed
                            }
                        }
                    NumberSelector(title: "Chapters read", num: $listStatus.numChaptersRead, max: manga.numChapters)
                        .onChange(of: listStatus.numChaptersRead) { prev, cur in
                            if listStatus.status == .planToRead && prev == 0 && cur > 0 {
                                listStatus.status = .reading
                            }
                            if settings.mangaReadProgress == 0, let numChapters = manga.numChapters, cur == numChapters && numChapters > 0 {
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
                        isConfirmingDelete = true
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
                    .confirmationDialog("Are you sure?", isPresented: $isConfirmingDelete) {
                        Button("Confirm", role: .destructive) {
                            Task {
                                isDeleting = true
                                do {
                                    try await networker.deleteUserManga(id: manga.id)
                                    dismiss()
                                } catch {
                                    isDeleteError = true
                                }
                                isDeleting = false
                            }
                        }
                        .disabled(isLoading || isDeleting)
                    } message: {
                        Text("This will remove the manga from your list")
                    }
                }
            } photo: {
                ImageFrame(id: "manga\(manga.id)", imageUrl: manga.mainPicture?.large, imageSize: .medium)
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
                                try await networker.editUserManga(id: manga.id, listStatus: listStatus)
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
        .onChange(of: scenePhase) {
            if scenePhase == .inactive && settings.useFaceID {
                dismiss()
            }
        }
    }
}
