//
//  ContentView.swift
//  URL Shortener
//
//  Created by Hans Rietmann on 20/05/2022.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        ShortenLinksView()
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.locale, .init(identifier: "fr"))
        ContentView()
            .environment(\.locale, .init(identifier: "en"))
        ContentView()
            .environment(\.locale, .init(identifier: "de"))
        ContentView()
            .environment(\.locale, .init(identifier: "it"))
    }
}
