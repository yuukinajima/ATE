//
//  SafariExtensionViewController.swift
//  Ex Extension
//
//  Created by yuki najima on 2024/04/24.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:320, height:240)
        return shared
    }()

}
