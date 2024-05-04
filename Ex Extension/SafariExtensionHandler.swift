//
//  SafariExtensionHandler.swift
//  Ex Extension
//
//  Created by yuki najima on 2024/04/24.
//

import SafariServices
import os.log

public enum Logger {
    public static let standard: os.Logger = .init(
        subsystem: Bundle.main.bundleIdentifier!,
        category: LogCategory.standard.rawValue
    )
}

// MARK: - Privates

private enum LogCategory: String {
     case standard = "Standard"
}

class SafariExtensionHandler: SFSafariExtensionHandler {

    override func beginRequest(with context: NSExtensionContext) {
        let request = context.inputItems.first as? NSExtensionItem

        let profile: UUID?
        if #available(iOS 17.0, macOS 14.0, *) {
            profile = request?.userInfo?[SFExtensionProfileKey] as? UUID
        } else {
            profile = request?.userInfo?["profile"] as? UUID
        }

        os_log(.default, "The extension received a request for profile: %@", profile?.uuidString ?? "none")
    }

    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        page.getPropertiesWithCompletionHandler { properties in
            os_log(.default, "The extension received a message (%@) from a script injected into (%@) with userInfo (%@)", messageName, String(describing: properties?.url), userInfo ?? [:])
        }
    }

    override func toolbarItemClicked(in window: SFSafariWindow) {
        os_log(.default, "The extension's toolbar item was clicked")
    }

    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        validationHandler(true, "")
    }

    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }


    override func page(_ page: SFSafariPage, willNavigateTo url: URL?) {

        page.getPropertiesWithCompletionHandler( {(_ p: SFSafariPageProperties?) -> Void in
            guard let page_ = p else {
                Logger.standard.info("getPropertiesWithCompletionHandler guard: page_ is nil")
                return
            }
            guard let url = page_.url else{
                Logger.standard.info("getPropertiesWithCompletionHandler guard: url is nil")
                return
            }
            Logger.standard.info("getPropertiesWithCompletionHandler \(url, privacy: .public)")

        })

        guard let nexturl = url else{
            Logger.standard.info("Info page guard \(page , privacy: .public)")
            return
        }

        Logger.standard.info("Info page \(nexturl.path())")
        print("page event \(nexturl.path())")

    }

    func handler(_ p: SFSafariPageProperties?) {

    }

}
