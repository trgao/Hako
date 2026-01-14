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
    @EnvironmentObject private var settings: SettingsManager
    @Binding private var urlToOpen: URL?
    
    init(url: Binding<URL?>) {
        self._urlToOpen = url
    }

    func body(content: Content) -> some View {
        if settings.safariInApp {
            content
                .environment(\.openURL, OpenURLAction { url in
                    guard let scheme = url.scheme?.lowercased() else {
                        return .systemAction
                    }

                    if scheme == "http" || scheme == "https" {
                        // Catch any URLs that are about to be opened in an external browser.
                        // Instead, handle them here and store the URL to reopen in our sheet.
                        urlToOpen = url
                        return .handled
                    } else {
                        // Let the system open app links
                        return .systemAction
                    }
                })
                .sheet(isPresented: $urlToOpen.mappedToBool(), onDismiss: {
                    urlToOpen = nil
                }, content: {
                    SafariView(url: urlToOpen!)
                })
        } else {
            content
        }
    }
}

extension Binding where Value == Bool {
    init(binding: Binding<(some Any)?>) {
        self.init(
            get: {
                binding.wrappedValue != nil
            },
            set: { newValue in
                guard newValue == false else { return }

                // We only handle `false` booleans to set our optional to `nil`
                // as we can't handle `true` for restoring the previous value.
                binding.wrappedValue = nil
            }
        )
    }
}

extension Binding {
    // Maps an optional binding to a `Binding<Bool>`.
    // This can be used to, for example, use an `Error?` object to decide whether or not to show an
    // alert, without needing to rely on a separately handled `Binding<Bool>`.
    func mappedToBool<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
        Binding<Bool>(binding: self)
    }
}

extension View {
    // Monitor the `openURL` environment variable and handle them in-app instead of via
    // the external web browser.
    // Uses the `SafariViewWrapper` which will present the URL in a `SFSafariViewController`.
    func handleOpenURLInApp(url: Binding<URL?>) -> some View {
        modifier(SafariViewControllerViewModifier(url: url))
    }
}
