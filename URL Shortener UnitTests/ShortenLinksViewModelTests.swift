//
//  ShortenLinksViewModelTests.swift
//  URL Shortener UnitTests
//
//  Created by Hans Rietmann on 20/05/2022.
//

import XCTest
@testable import URL_Shortener




@MainActor
class ShortenLinksViewModelTests: XCTestCase {
    
    let correctLink = "https://www.openwt.com/en/cases/artificial-intelligence-brings-customer-service-30"
    let correctLinkShorten = "http://tinyurl.com/aze-rty-uio"
    var correctLinkShortenURL: URL { .init(string: correctLinkShorten)! }
    var correctShortenURL: ShortenURL { try! .init(long: correctLink, shorten: correctLinkShorten) }
    
    func test_shorten_correct_remote_link() async {
        let shortenURLProvider = ShortenURLFetcherTests()
        shortenURLProvider.remotelyShortenResult = { [unowned self] longLink in
            .init { try ShortenURL(long: longLink, shorten: self.correctLinkShorten) }
        }
        
        let sut = ShortenLinksViewModel(shortenURLProvider: shortenURLProvider)
        await sut.shorten(link: correctLink)
        
        XCTAssertEqual(sut.newShortenURL?.url, correctLinkShortenURL)
        XCTAssertFalse(sut.isShortening)
        XCTAssertNil(sut.shortenError)
    }
    
    func test_shorten_incorrect_remote_link() async {
        let provider = ShortenURLFetcherTests()
        provider.remotelyShortenResult = { longLink in
                .failure(AppError.invalidOrginalURLLink(link: longLink))
        }
        let invalidLink = "azertyuiop"
        
        let sut = ShortenLinksViewModel(shortenURLProvider: provider)
        await sut.shorten(link: invalidLink)
        
        XCTAssertEqual(sut.shortenError, AppError.invalidOrginalURLLink(link: invalidLink))
    }
    
    func test_shorten_existing_link() async {
        let provider = ShortenURLFetcherTests()
        provider.localyStoredShortenResult = { [unowned self] link in
            .success(self.correctShortenURL)
        }
        
        let sut = ShortenLinksViewModel(shortenURLProvider: provider)
        await sut.shorten(link: correctLink)
        
        XCTAssertEqual(sut.shortenError, AppError.linkAlreadyShortened(shortenURL: correctShortenURL))
    }
    
    func test_recently_shorten_links_correct_load() {
        let provider = ShortenURLFetcherTests()
        let cachedURLs = (0...3).map { _ in try! ShortenURL(long: correctLink, shorten: correctLinkShorten) }
        provider.cachedURLsResult = .success(cachedURLs)
        
        let sut = ShortenLinksViewModel(shortenURLProvider: provider)
        sut.loadShortenURLs()
        
        XCTAssertEqual(cachedURLs, sut.shortenURLs)
        XCTAssertNil(sut.shortenError)
    }
    
}
