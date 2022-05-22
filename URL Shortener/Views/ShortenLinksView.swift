//
//  ShortenLinksView.swift
//  URL Shortener
//
//  Created by Hans Rietmann on 22/05/2022.
//

import SwiftUI
import SafariServices


struct ShortenLinksView: View {
    
    @State private var textEntry = ""
    @State private var presentError = false
    @StateObject var model = ShortenLinksViewModel()
    @FocusState private var linkFieldIsFocused: Bool
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            // List/Grid of recently shortened URLs
            ScrollView {
                Group {
                    if horizontalSizeClass == .compact {
                        LazyVStack(spacing: 16) { items }
                    } else {
                        LazyVGrid(
                            columns: [
                                .init(.flexible(minimum: 200, maximum: .infinity), spacing: 16, alignment: .top),
                                .init(.flexible(minimum: 200, maximum: .infinity), spacing: 16, alignment: .top)
                            ], alignment: .center, spacing: 16
                        ) { items }
                    }
                }
                .padding()
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .task { model.loadShortenURLs() }
        .onChange(of: model.isShortening) { _ in
            presentError = model.shortenError != nil
        }
        .onChange(of: model.newShortenURL) { newValue in
            guard newValue != nil else { return }
            textEntry = ""
        }
        .alert(isPresented: $presentError, error: model.shortenError) { _ in
            // Buttons
        } message: { Text($0.message) }
        
    }
    
    var header: some View {
        VStack {
            
            // App logo
            Text("URL Shortener")
                .font(.largeTitle.weight(.bold))
                .foregroundColor(.white)
                .accessibilityHidden(true)
            
            // Search field
            HStack {
                TextField("ShortenLinksView.textfield.placeholder", text: $textEntry)
                    .submitLabel(.send)
                    .font(.subheadline.weight(.medium))
                    .padding(.vertical)
                    .focused($linkFieldIsFocused)
                    .onSubmit {
                        submit()
                        linkFieldIsFocused = false
                    }
                Button {
                    submit()
                } label: {
                    if model.isShortening {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.right")
                    }
                }
                .font(.body.weight(.bold))
                .padding(10)
                .background(Color.accentColor)
                .clipShape(Circle())
                .shadow(radius: 3, x: 1, y: 2)
                .tint(.white)
                .disabled(model.isShortening)
                .disabled(!textEntryIsValidURL)
                .animation(.spring(), value: model.isShortening)
            }
            .padding(.leading)
            .padding(.trailing, 6)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(radius: 6, x: 1, y: 2)
            .accessibilityAddTraits(.isSearchField)
        }
        .padding()
        .background(Color.navigationColor)
    }
    
    var items: some View {
        ForEach(model.shortenURLs) { shortenURL in
            ShortenLinkRow(shortenURL: shortenURL)
        }
    }
    
    var textEntryIsValidURL: Bool {
        guard let url = URL(string: textEntry),
              UIApplication.shared.canOpenURL(url)
        else { return false }
        return true
    }
    
    func submit() {
        defer { linkFieldIsFocused = false }
        guard textEntryIsValidURL else { return }
        Task { await model.shorten(link: textEntry) }
    }
    
}

struct ShortenLinksView_Previews: PreviewProvider {
    static var previews: some View {
        ShortenLinksView()
            .environment(\.locale, .init(identifier: "en"))
    }
}
