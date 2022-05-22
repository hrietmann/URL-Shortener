//
//  ShortenLinksViewModel.swift
//  URL Shortener
//
//  Created by Hans Rietmann on 22/05/2022.
//

import SwiftUI



/// ``ShortenLinksView`` viewmodel.
@MainActor
final class ShortenLinksViewModel: ObservableObject {
    
    
    
    /// Service provider handling remote data tasks and local data tasks.
    /// The ``ShortenURLFetcher`` provider is the default one to use.
    private let shortenURLProvider: ShortenURLProvider
    
    /// Holds all the recently shortened URLs ``ShortenURL`` in the descending order.
    @Published private(set) var shortenURLs = [ShortenURL]()
    /// Stores the shortening task status ``TaskStatus``.
    @Published private var shortenTask: TaskStatus<ShortenURL, Error>? {
        willSet {
            guard case let .inProgress(previousTask) = shortenTask else { return }
            guard !previousTask.isCancelled else { return }
            previousTask.cancel()
        }
    }
    /// Flag indicating if the shortening task is in progress or not.
    var isShortening: Bool {
        guard case .inProgress = shortenTask else { return false }
        return true
    }
    /// Current ``ShortenURL`` returned by the task.
    var newShortenURL: ShortenURL? {
        guard case let .fetched(shortenURL) = shortenTask else { return nil }
        return shortenURL
    }
    /// Current shortened ``AppError`` thrown back by the the shortened task.
    var shortenError: AppError? {
        guard case let .failed(error) = shortenTask else { return nil }
        return AppError.localize(error: error)
    }
    
    
    
    init(shortenURLProvider: ShortenURLProvider = ShortenURLFetcher()) {
        self.shortenURLProvider = shortenURLProvider
    }
    
    
    
    func loadShortenURLs() {
        do { shortenURLs = try shortenURLProvider.cachedURLs }
        catch { shortenTask = .failed(error) }
    }
    
    /// Launch the URL shortening processes.
    /// - Parameter link: URL to shorten
    func shorten(link: String) async {
        
        // Prepare the background task to make the shorten remotely
        let task: Task<ShortenURL, Error> = .detached { [weak self] in
            guard let fetcher = self?.shortenURLProvider
            else { throw AppError.shortenURLProviderRemovedFromMemory }
            let remoteURL = try await fetcher.remotelyShorten(link: link)
            try fetcher.saveLocally(shorten: remoteURL)
            return remoteURL
        }
        
        // Load status handling
        shortenTask = .inProgress(task)
        do {
            // Throw an error when the URL has already been shortened before to limit unecessary duplicates
            if let url = try shortenURLProvider.cachedShorten(link: link)
            { throw AppError.linkAlreadyShortened(shortenURL: url) }
            
            let shortenURL = try await task.value
            shortenURLs.insert(shortenURL, at: 0)
            shortenTask = .fetched(shortenURL)
        } catch { shortenTask = .failed(error) }
    }
    
    
    
}
