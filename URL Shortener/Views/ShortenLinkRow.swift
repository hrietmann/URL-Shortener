//
//  ShortenLinkRow.swift
//  URL Shortener
//
//  Created by Hans Rietmann on 22/05/2022.
//

import SwiftUI


struct ShortenLinkRow: View {
    
    let shortenURL: ShortenURL
    @State private var presentSafari = false
    private var buttonAccessibilityLabel: String {
        String(
            format: NSLocalizedString("ShortenLinkRow.Accessibility.Button", comment: "ShortenLinkRow Button Description"),
            shortenURL.url.absoluteString,
            shortenURL.originalURL.host ?? shortenURL.originalURL.absoluteString,
            DateFormatter.localizedString(
                from: shortenURL.date,
                dateStyle: .short,
                timeStyle: .short
            )
        )
    }
    
    var body: some View {
        Button {
            presentSafari.toggle()
        } label: {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(shortenURL.url.absoluteString)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(Color.navigationColor)
                            Text(shortenURL.originalURL.absoluteString)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(shortenURL.date, format: .dateTime)
                        .font(.caption.weight(.medium))
                        .foregroundColor(Color(uiColor: .tertiaryLabel))
                }
                Image(systemName: "arrow.up.right")
                    .font(.title3.weight(.bold))
                    .foregroundColor(Color.accentColor)
            }
            .padding()
        }
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8).stroke(.secondary, lineWidth: 0.2)
        }
        .shadow(color: .black.opacity(0.2), radius: 8, x: 2, y: 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(buttonAccessibilityLabel)
        .sheet(isPresented: $presentSafari) {
            SafariView(url: shortenURL.originalURL)
        }
    }
}

struct ShortenLinkRow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ShortenLinkRow(shortenURL: .dummy)
                .padding()
                .navigationBarHidden(true)
        }
    }
}
