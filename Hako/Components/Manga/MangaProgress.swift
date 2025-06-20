//
//  MangaProgress.swift
//  Hako
//
//  Created by Gao Tianrun on 19/6/25.
//

import SwiftUI

struct MangaProgress: View {
    @EnvironmentObject private var settings: SettingsManager
    private var numChapters: Int?
    private var numVolumes: Int?
    private var numChaptersRead: Int
    private var numVolumesRead: Int
    private var status: StatusEnum?
    private let colours: [StatusEnum:Color] = [
        .reading: Color(.systemGreen),
        .completed: Color(.systemBlue),
        .onHold: Color(.systemYellow),
        .dropped: Color(.systemRed),
        .planToRead: .primary,
        .none: Color(.systemGray)
    ]
    
    init(numChapters: Int?, numVolumes: Int?, numChaptersRead: Int, numVolumesRead: Int, status: StatusEnum?) {
        self.numChapters = numChapters
        self.numVolumes = numVolumes
        self.numChaptersRead = numChaptersRead
        self.numVolumesRead = numVolumesRead
        self.status = status
    }
    
    var body: some View {
        ScrollViewSection(title: "Your progress") {
            VStack {
                if settings.mangaReadProgress == 0 {
                    if let numChapters = numChapters, numChapters > 0 {
                        ProgressView(value: Float(numChaptersRead) / Float(numChapters))
                            .tint(colours[status ?? .none])
                        HStack {
                            Text(status?.toString() ?? "")
                                .bold()
                            Spacer()
                            if let numVolumes = numVolumes, numVolumes > 0 {
                                Label("\(String(numVolumesRead)) / \(String(numVolumes))", systemImage: "book.closed.fill")
                                    .labelStyle(CustomLabel(spacing: 2))
                            } else {
                                Label("\(String(numVolumesRead)) / ?", systemImage: "book.closed.fill")
                                    .labelStyle(CustomLabel(spacing: 2))
                            }
                            Label("\(String(numChaptersRead)) / \(String(numChapters))", systemImage: "book.pages.fill")
                                .labelStyle(CustomLabel(spacing: 2))
                        }
                    } else {
                        ProgressView(value: numChaptersRead == 0 ? 0 : 0.5)
                            .tint(colours[status ?? .none])
                        HStack {
                            Text(status?.toString() ?? "")
                                .bold()
                            Spacer()
                            if let numVolumes = numVolumes, numVolumes > 0 {
                                Label("\(String(numVolumesRead)) / \(String(numVolumes))", systemImage: "book.closed.fill")
                                    .labelStyle(CustomLabel(spacing: 2))
                            } else {
                                Label("\(String(numVolumesRead)) / ?", systemImage: "book.closed.fill")
                                    .labelStyle(CustomLabel(spacing: 2))
                            }
                            Label("\(String(numChaptersRead)) / ?", systemImage: "book.pages.fill")
                                .labelStyle(CustomLabel(spacing: 2))
                        }
                    }
                } else {
                    if let numVolumes = numVolumes, numVolumes > 0 {
                        ProgressView(value: Float(numVolumesRead) / Float(numVolumes))
                            .tint(colours[status ?? .none])
                        HStack {
                            Text(status?.toString() ?? "")
                                .bold()
                            Spacer()
                            Label("\(String(numVolumesRead)) / \(String(numVolumes))", systemImage: "book.closed.fill")
                                .labelStyle(CustomLabel(spacing: 2))
                            if let numChapters = numChapters, numChapters > 0 {
                                Label("\(String(numChaptersRead)) / \(String(numChapters))", systemImage: "book.pages.fill")
                                    .labelStyle(CustomLabel(spacing: 2))
                            } else {
                                Label("\(String(numChaptersRead)) / ?", systemImage: "book.pages.fill")
                                    .labelStyle(CustomLabel(spacing: 2))
                            }
                        }
                    } else {
                        ProgressView(value: numVolumesRead == 0 ? 0 : 0.5)
                            .tint(colours[status ?? .none])
                        HStack {
                            Text(status?.toString() ?? "")
                                .bold()
                            Spacer()
                            Label("\(String(numVolumesRead)) / ?", systemImage: "book.closed.fill")
                                .labelStyle(CustomLabel(spacing: 2))
                            if let numChapters = numChapters, numChapters > 0 {
                                Label("\(String(numChaptersRead)) / \(String(numChapters))", systemImage: "book.pages.fill")
                                    .labelStyle(CustomLabel(spacing: 2))
                            } else {
                                Label("\(String(numChaptersRead)) / ?", systemImage: "book.pages.fill")
                                    .labelStyle(CustomLabel(spacing: 2))
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
    }
}
