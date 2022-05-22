//
//  ShortenURLFetcherTests.swift
//  URL Shortener UnitTests
//
//  Created by Hans Rietmann on 22/05/2022.
//

import Foundation
@testable import URL_Shortener




final class ShortenURLFetcherTests: ShortenURLProvider {
    
    
    
    var cachedURLs: [ShortenURL] {
        get throws {
            try cachedURLsResult.get()
        }
    }
    var remotelyShortenResult: (String) -> Result<ShortenURL, Error> = { longLink in
            .init { try ShortenURL(long: longLink, shorten: longLink) }
    }
    var saveResult: Result<Void, Error> = .success(())
    var cachedURLsResult: Result<[ShortenURL], Error> = .success([])
    var localyStoredShortenResult: (String) -> Result<ShortenURL?, Error> = { _ in .success(nil) }
    
    
    
    init() {
        
    }
    
    
    
    func remotelyShorten(link: String) async throws -> ShortenURL {
        try remotelyShortenResult(link).get()
    }
    func saveLocally(shorten: ShortenURL) throws {
        try saveResult.get()
    }
    func cachedShorten(link: String) throws -> ShortenURL? {
        try localyStoredShortenResult(link).get()
    }
    
    
    
}
