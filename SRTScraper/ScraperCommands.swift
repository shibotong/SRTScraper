//
//  ScraperCommands.swift
//  SRTScraper
//
//  Created by Shibo Tong on 11/8/2023.
//

import SwiftUI

struct ScraperCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            openVideoButton
        }
    }
    
    private var openVideoButton: some View {
        Button("Open Video", action: {
            // Implement the action to open a video file here
            let openPanel = NSOpenPanel()
            openPanel.allowedContentTypes = [.movie] // Add other supported video formats
            
            if openPanel.runModal() == .OK {
                if let url = openPanel.url {
                    // Handle the selected video URL (e.g., play it using AVPlayer)
                    // Implement the appropriate video player logic here
                    ScraperEnvironment.shared.openVideo(path: url)
                }
            }
        })
        .keyboardShortcut("o", modifiers: .command)
    }
}

