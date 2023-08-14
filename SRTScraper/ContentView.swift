//
//  ContentView.swift
//  SRTScraper
//
//  Created by Shibo Tong on 11/8/2023.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var environment: ScraperEnvironment
    
    @State private var isShareSheetPresented = false
    
    var body: some View {
        VStack {
            VideoSelectionView(selectionRect: $environment.cropSize, videoPlayer: environment.videoPlayer)
                .padding(30)
            if environment.isProcessing {
                ProgressView(value: environment.progress)
                    .progressViewStyle(.linear)
                    .frame(width: 640)
            } else {
                HStack {
                    scrapButton
                    exportButton
                }
            }
            SubtitlesView(subtitles: environment.subtitles)
                .frame(minHeight: 300)
        }
        .fileExporter(isPresented: $isShareSheetPresented, document: environment.document, contentType: .plainText) { result in
            switch result {
            case .success(let file):
                print(file)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private var scrapButton: some View {
        Button("Generate SRT subtitle") {
            Task {
                await environment.scrapVideo()
            }
        }
    }
    
    private var exportButton: some View {
        Button("Export File") {
            environment.generateDocument()
            isShareSheetPresented.toggle()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ScraperEnvironment.shared)
    }
}
