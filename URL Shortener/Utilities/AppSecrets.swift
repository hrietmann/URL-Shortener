//
//  AppSecrets.swift
//  URL Shortener
//
//  Created by Hans Rietmann on 22/05/2022.
//

import Foundation



/// Object referencing to the `AppSecrets.json` file containing API keys, endpoints, tokens, ...
/// The file should NOT be shared publicly and SHOULD be listed in the `gitignore`.
struct AppSecrets: Codable {
    
    let TINYURL_API_ROOT: URL
    
    private init(url: URL) { TINYURL_API_ROOT = url }
}


extension AppSecrets {
    
    fileprivate static var appSecrets: AppSecrets {
        guard let url = Bundle.main.url(forResource: "AppSecrets", withExtension: "json")
        else { fatalError("AppSecrets.json not found. Import this file to the project to be able to uses its services.") }
        guard let secrets = try? JSONDecoder().decode(AppSecrets.self, from: Data(contentsOf: url))
        else { fatalError("Unable to read the AppSecrets.json file.") }
        return secrets
    }
    
}


extension ShortenURLProvider {
    
    var appSecrets: AppSecrets { .appSecrets }
    var tinyURLapiRoot: URL { appSecrets.TINYURL_API_ROOT }
    
}
