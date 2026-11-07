//
//  SafariView.swift
//  Code adapted from https://www.avanderlee.com/swiftui/sfsafariviewcontroller-open-webpages-in-app/
//

import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    private let url: URL

    init(url: URL) {
        self.url = url
    }

    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

private struct SafariViewControllerViewModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var settings: SettingsManager
    @Binding private var urlToOpen: URL?

    private var urlBinding: Binding<IdentifiableURL?> {
        Binding(
            get: {
                if let urlToOpen {
                    IdentifiableURL(url: urlToOpen)
                } else {
                    nil
                }
            },
            set: { _ in
                urlToOpen = nil
            }
        )
    }

    init(url: Binding<URL?>) {
        self._urlToOpen = url
    }

    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction { url in
                guard let scheme = url.scheme?.lowercased(), settings.safariInApp && !ProcessInfo.processInfo.isMacCatalystApp else {
                    return .systemAction
                }

                if (scheme == "http" || scheme == "https") && url.host != "music.apple.com" {
                    // Catch any URLs that are about to be opened in an external browser.
                    // Instead, handle them here and store the URL to reopen in our sheet.
                    urlToOpen = url
                    return .handled
                } else {
                    // Let the system open app links
                    return .systemAction
                }
            })
            .sheet(item: urlBinding) { item in
                SafariView(url: item.url)
            }
            .onChange(of: scenePhase) {
                if scenePhase == .inactive && settings.useFaceID {
                    urlToOpen = nil
                }
            }
    }
}

struct IdentifiableURL: Identifiable {
    let url: URL
    var id: URL { url }
}

extension View {
    // Monitor the `openURL` environment variable and handle them in-app instead of via
    // the external web browser.
    // Uses the `SafariViewWrapper` which will present the URL in a `SFSafariViewController`.
    func handleOpenURLInApp(url: Binding<URL?>) -> some View {
        modifier(SafariViewControllerViewModifier(url: url))
    }
}
