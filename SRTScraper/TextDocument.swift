//
//  TextDocument.swift
//  SRTScraper
//
//  Created by Shibo Tong on 12/8/2023.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct TextDocument: FileDocument {
    static var readableContentTypes: [UTType] {
        [.plainText]
    }
    
    var text = ""
    
    init(text: String) {
        self.text = text
    }
    
    init(subtitles: [Subtitle]) {
        var text = ""
        var row = 0
        for subtitle in subtitles {
            row += 1
            text += "\(row)\n"
            text += "\(subtitle.startTime.formatTime) --> \(subtitle.endTime.formatTime)\n"
            text += "\(subtitle.text)\n"
            text += "\n"
        }
        self.text = text
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        } else {
            text = ""
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(text.utf8))
    }
}
