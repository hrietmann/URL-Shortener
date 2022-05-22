//
//  SafariView.swift
//  URL Shortener
//
//  Created by Hans Rietmann on 22/05/2022.
//

import SwiftUI
import SafariServices



#warning("Memory leak detected when the SafariView is presented and then dismissed.")

/// View containing the default in-app Webview of Safari ``SFSafariViewController``.
struct SafariView: UIViewControllerRepresentable {
    
    
    let url: URL

    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        controller.preferredControlTintColor = .navigationColor
        return controller
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
        
    }
    
    
}
