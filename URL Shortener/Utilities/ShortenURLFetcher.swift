//
//  ShortenURLFetcher.swift
//  URL Shortener
//
//  Created by Hans Rietmann on 22/05/2022.
//

import Foundation
import CoreData



protocol ShortenURLProvider {
    var cachedURLs: [ShortenURL] { get throws }
    func remotelyShorten(link: String) async throws -> ShortenURL
    func saveLocally(shorten: ShortenURL) throws
    func cachedShorten(link: String) throws -> ShortenURL?
}



final class ShortenURLFetcher: ShortenURLProvider {
    
    
    var cachedURLs: [ShortenURL] {
        get throws {
            let fetch = ShortenURLEntity.fetchRequest()
            fetch.sortDescriptors = [.init(key: "date", ascending: false)]
            let results = try managedObjectContext.fetch(fetch)
            return results.compactMap { ShortenURL(entity: $0) }
        }
    }
    private let container = NSPersistentContainer(name: "Model")
    private var managedObjectContext: NSManagedObjectContext { container.viewContext }
    
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("An issue emmerged during persistant stores load: \(error.localizedDescription)")
            }
        }
    }
    
    func remotelyShorten(link: String) async throws -> ShortenURL {
        let operationStart = Date()
        
        var urlComponents = URLComponents(string: tinyURLapiRoot.absoluteString)
        urlComponents?.queryItems = [
            .init(name: "url", value: link)
        ]
        guard let queryURL = urlComponents?.url
        else { fatalError("Incorrect query URL generated from URL components.") }
        
        var request = URLRequest(url: queryURL)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Enables the user to see the loading wheel spinning for at least a second
        if abs(operationStart.timeIntervalSinceNow) < 1 {
            try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        }
        
        if let response = response as? HTTPURLResponse, response.statusCode >= 400 {
            throw AppError.badResponseReceived(response: response)
        }
        guard let shortenLink = String(data: data, encoding: .utf8)
        else { throw AppError.noShortenURLGiven }
        return try .init(long: link, shorten: shortenLink)
    }
    
    func saveLocally(shorten: ShortenURL) throws {
        let entity = ShortenURLEntity(context: managedObjectContext)
        entity.id = shorten.id
        entity.date = shorten.date
        entity.originalURL = shorten.originalURL
        entity.url = shorten.url
        try managedObjectContext.save()
    }
    
    func cachedShorten(link: String) throws -> ShortenURL? {
        guard let originalURL = URL(string: link) else { return nil }
        let fetch = ShortenURLEntity.fetchRequest()
        fetch.predicate = NSPredicate(format: "originalURL == %@", originalURL as CVarArg)
        fetch.sortDescriptors = [.init(key: "date", ascending: false)]
        do {
            guard let entity = try managedObjectContext.fetch(fetch).first else { return nil }
            return .init(entity: entity)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
}
