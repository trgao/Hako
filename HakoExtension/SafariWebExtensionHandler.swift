//
//  SafariWebExtensionHandler.swift
//  HakoExtension
//  Extension code (including JS scripts) adapted from https://github.com/christianselig/OpenInApolloExtension
//

import SafariServices
import os.log

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    func beginRequest(with context: NSExtensionContext) {
        let request = context.inputItems.first as? NSExtensionItem

        let profile: UUID?
        profile = request?.userInfo?["profile"] as? UUID

        let message: Any?
        message = request?.userInfo?["message"]

        os_log(.default, "Received message from browser.runtime.sendNativeMessage: %@ (profile: %@)", String(describing: message), profile?.uuidString ?? "none")

        let response = NSExtensionItem()
        response.userInfo = [ "message": [ "echo": message ] ]

        context.completeRequest(returningItems: [ response ], completionHandler: nil)
    }
}
