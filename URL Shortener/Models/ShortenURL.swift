//
//  ShortenURL.swift
//  URL Shortener
//
//  Created by Hans Rietmann on 21/05/2022.
//

import Foundation




struct ShortenURL {
    
    let id: UUID
    /// When shortening was done
    let date: Date
    /// Oringial URL that was requested to be shortened
    let originalURL: URL
    /// Shortened URL given by the REST API
    let url: URL
    
    init(long: String, shorten: String) throws {
        guard let originalURL = URL(string: long) else { throw AppError.invalidOrginalURLLink(link: long) }
        guard let url = URL(string: shorten) else { throw AppError.badlyFormattedShortenURL(shortenLink: shorten) }
        id = UUID()
        date = Date()
        self.originalURL = originalURL
        self.url = url
    }
    
    init?(entity: ShortenURLEntity) {
        guard let id = entity.id,
              let date = entity.date,
              let originalURL = entity.originalURL,
              let url = entity.url
        else { return nil }
        self.id = id
        self.date = date
        self.originalURL = originalURL
        self.url = url
    }
    
}



extension ShortenURL: Identifiable, Hashable, Equatable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(date)
        hasher.combine(originalURL)
        hasher.combine(url)
    }
    
    static func == (lhs: ShortenURL, rhs: ShortenURL) -> Bool { lhs.id == rhs.id }
    
}



extension ShortenURL {
    
    static var dummy: ShortenURL {
        try! .init(
            long: "https://docs.swift.org/swift-book/ReferenceManual/AboutTheLanguageReference.html",
            shorten: "http://tinyurl.com/aze-rty-yui"
        )
    }
    
}
