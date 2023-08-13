//
//  SubtitlesView.swift
//  SRTScraper
//
//  Created by Shibo Tong on 12/8/2023.
//

import SwiftUI

struct SubtitlesView: View {
    
    var subtitles: [Subtitle]
    
    var body: some View {
        Table(subtitles) {
            TableColumn("start", value: \.startTime.seconds.description)
            TableColumn("end", value: \.endTime.seconds.description)
            TableColumn("text", value: \.text)
        }
    }
}

struct SubtitlesView_Previews: PreviewProvider {
    static var previews: some View {
        SubtitlesView(subtitles: [Subtitle(text: "abc", startTime: .zero, endTime: .zero)])
    }
}
