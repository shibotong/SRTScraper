//
//  CMTime+Extension.swift
//  SRTScraper
//
//  Created by Shibo Tong on 12/8/2023.
//

import Foundation
import AVFoundation

extension CMTime {
    var formatTime: String {
        let totalSeconds = CMTimeGetSeconds(self)
        
        let hours = Int(totalSeconds / 3600)
        let minutes = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        let milliseconds = Int((totalSeconds.truncatingRemainder(dividingBy: 1)) * 1000)
        
        return String(format: "%02d:%02d:%02d,%03d", hours, minutes, seconds, milliseconds)
    }
}
