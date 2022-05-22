//
//  AppError.swift
//  URL Shortener
//
//  Created by Hans Rietmann on 22/05/2022.
//

import Foundation





struct AppError: LocalizedError {
    
    
    let title: String
    let message: String
    
    var errorDescription: String? { title }
    
    private init(title: String, message: String) {
        self.title = title
        self.message = message
    }
    
    
    /// Transforms any error to a localized ``AppError``
    /// - Parameter error: error to transform
    /// - Returns: transformed localized error
    static func localize(error: Error) -> AppError {
        if let appError = error as? AppError { return appError }
        
        let defaultTitle = String(
            format: NSLocalizedString("AppError.genericError.title", comment: "Unknown error title")
        )
        if let localizedError = error as? LocalizedError {
            return .init(
                title: localizedError.errorDescription ?? defaultTitle,
                message: localizedError.failureReason ?? localizedError.localizedDescription
            )
        }
        
        let messageKey = NSLocalizedString("AppError.genericError.message", comment: "Unknown error message")
        let defaultMessage = String(format: messageKey, error.localizedDescription)
        return .init(title: defaultTitle, message: defaultMessage)
    }
    
    
    /// Creates invalid original URL error
    /// - Parameter link: link to be shortened
    /// - Returns: localized error ``AppError``
    static func invalidOrginalURLLink(link: String) -> AppError {
        .init(
            title: String(
                format: NSLocalizedString("AppError.invalidOrginalURLLink.title", comment: "Invalid URL link error title")
            ),
            message: String(
                format: NSLocalizedString("AppError.invalidOrginalURLLink.message", comment: "Invalid URL link error message"),
                link
            )
        )
    }
    
    
    /// Creates bad URL format error for the shortened URL given back by the REST API
    /// - Parameter shortenLink: URL link given back by the server
    /// - Returns: localized error ``AppError``
    static func badlyFormattedShortenURL(shortenLink: String) -> AppError {
        .init(
            title: String(
                format: NSLocalizedString("AppError.badlyFormattedShortenURL.title", comment: "Services error title")
            ),
            message: String(
                format: NSLocalizedString("AppError.badlyFormattedShortenURL.message", comment: "Services error message"),
                shortenLink
            )
        )
    }
    
    
    /// Creates a localized ``AppError`` for when no shortened URL was given back from the API request
    static var noShortenURLGiven: AppError {
        .init(
            title: String(
                format: NSLocalizedString("AppError.noShortenURLGiven.title", comment: "Services error title")
            ),
            message: String(
                format: NSLocalizedString("AppError.noShortenURLGiven.message", comment: "Services error message")
            )
        )
    }
    
    
    /// Creates a localized ``AppError`` for when the API service provider was removed from memory before the task finishes.
    static var shortenURLProviderRemovedFromMemory: AppError {
        .init(
            title: String(
                format: NSLocalizedString("AppError.shortenURLProviderRemovedFromMemory.title", comment: "Memory error title")
            ),
            message: String(
                format: NSLocalizedString("AppError.shortenURLProviderRemovedFromMemory.message", comment: "Memory error message")
            )
        )
    }
    
    
    /// Creates a localized ``AppError`` for when a bast response was received from a URLSession data task
    static func badResponseReceived(response: HTTPURLResponse) -> AppError {
        .init(
            title: String(
                format: NSLocalizedString("AppError.badResponseReceived.title", comment: "Services error title")
            ),
            message: String(
                format: NSLocalizedString("AppError.badResponseReceived.message", comment: "Services error message"),
                response.statusCode
            )
        )
    }
    
    
    /// Creates an error for already shortened URLs
    /// - Parameter shortenURL: existing URL already shortened
    /// - Returns: localized error ``AppError``
    static func linkAlreadyShortened(shortenURL: ShortenURL) -> AppError {
        .init(
            title: String(
                format: NSLocalizedString("AppError.linkAlreadyShortened.title", comment: "Shorten URL exists error title")
            ),
            message: String(
                format: NSLocalizedString("AppError.linkAlreadyShortened.message", comment: "Shorten URL exists error message"),
                shortenURL.url.absoluteString, shortenURL.originalURL.absoluteString
            )
        )
    }
    
    
    
}



extension AppError: Hashable, Equatable {
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(message)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool
    { lhs.title == rhs.title && lhs.message == rhs.message }
    
    
}
