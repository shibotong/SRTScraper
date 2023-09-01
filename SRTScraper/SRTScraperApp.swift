//
//  SRTScraperApp.swift
//  SRTScraper
//
//  Created by Shibo Tong on 11/8/2023.
//

import SwiftUI

@main
struct SRTScraperApp: App {
    
    @StateObject private var environment = ScraperEnvironment.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(environment)
                .navigationTitle($environment.title)
        }.commands {
            ScraperCommands()
        }
    }
}
