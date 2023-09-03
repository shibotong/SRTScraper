//
//  ScraperEnvironment.swift
//  SRTScraper
//
//  Created by Shibo Tong on 11/8/2023.
//

import Foundation
import AVKit
import SRTScraperOCR
import UserNotifications

class ScraperEnvironment: ObservableObject {
    
    static var shared = ScraperEnvironment()
    
    @Published var videoPlayer: AVPlayer?
    
    @Published var subtitles: [Subtitle] = []
    
    @Published var cropSize: CGRect = CGRect(x: 0, y: 0, width: 640, height: 360)
    
    @Published var title: String = "SRTScraper"
    
    private var frameExtractor: VideoFrameExtractor?
    
    @Published var progress: Double = 0.0
    @Published var isProcessing: Bool = false
    @Published var current: Int = 0
    @Published var total: Int = 0
    
    var document: TextDocument?
    
    func openVideo(path: URL) {
        videoPlayer = AVPlayer(url: path)
        guard let videoAsset = videoPlayer?.currentItem?.asset else {
            print("Failed to load video in to FrameExtractor")
            return
        }
        frameExtractor = VideoFrameExtractor(video: videoAsset)
        title = path.lastPathComponent
    }
    
    func generateDocument() {
        let document = TextDocument(subtitles: subtitles)
        self.document = document
    }
    
    @MainActor
    private func setProcessing(_ processing: Bool, value: Double) {
        isProcessing = processing
        progress = value
    }
    
    @MainActor
    private func setProgress(current: Int, total: Int) {
        self.current = current
        self.total = total
    }
    
    @MainActor
    private func resetSubtitle() {
        subtitles = []
    }
    
    func scrapVideo() async {
        await resetSubtitle()
        guard let seconds = videoPlayer?.currentItem?.duration.seconds else {
            return
        }
        await setProcessing(true, value: 0.0)
        do {
            let timeArray = try scrapSecond(seconds: seconds)
            await scrapFrames(frames: timeArray)
        } catch {
            print(error)
        }
        await setProcessing(false, value: 0.0)
        sendPushNotification()
    }
    
    private func scrapSecond(seconds: Double) throws -> [CMTime] {
        let interval: Double = Constants.scrapInterval
        var timeArray: [CMTime] = []
        for i in stride(from: 0.0, through: seconds, by: interval) {
            let cmTime = CMTime(seconds: i, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            timeArray.append(cmTime)
        }
        return timeArray
    }
    
    private func scrapFrames(frames: [CMTime]) async {
        guard var frameExtractor else {
            return
        }
        frameExtractor.frames = frames
        
        let images = frameExtractor.generateImages()
        let total = frames.count
        var processing = 0
        var lastText: String?
        var lastTime: CMTime?
        for await result in images {
            processing += 1
            let progress = Double(processing) / Double(total)
            await setProcessing(true, value: progress)
            switch result {
            case .success(requestedTime: _, image: let image, actualTime: let time):
                await setToTime(time: time)
                do {
                    let cropedImage = try cropImage(image: image)
                    let text = await ocrReading(image: cropedImage)
                    if lastText != nil, lastTime != nil {
                        if lastText!.distance(text) < Constants.similarityPercentage {
                            await addToSubtitle(text: lastText!, startTime: lastTime!, endTime: time)
                            if text != "" {
                                lastText = text
                                lastTime = time
                            } else {
                                lastText = nil
                                lastTime = nil
                            }
                        }
                    } else {
                        if text != "" {
                            lastText = text
                            lastTime = time
                        }
                    }
                    if text != lastText {
                        lastText = text
                    }
                } catch {
                    print("Image crop failure at: \(time)")
                    continue
                }
            case .failure(requestedTime: _, error: let error):
                print(error)
            }
        }
    }
    
    private func cropImage(image: CGImage) throws -> CGImage {
        guard let videoSize = videoPlayer?.currentItem?.presentationSize else {
            throw SRTScraperError.missingVideoError
        }
        let cropRect = scaledCropRectToOriginalSize(originalSize: videoSize)
        guard let cropImage = image.cropping(to: cropRect) else {
            throw SRTScraperError.cropImageError
        }
        return cropImage
    }
    
    private func scaledCropRectToOriginalSize(originalSize: CGSize) -> CGRect {
        let scaledWidth: CGFloat = 640
        let scaledHeight: CGFloat = 360
        let originalWidth = originalSize.width * (cropSize.width / scaledWidth)
        let originalHeight = originalSize.height * (cropSize.height / scaledHeight)
        
        let scaledX = cropSize.origin.x - cropSize.width / 2 + scaledWidth / 2
        let scaledY = cropSize.origin.y - cropSize.height / 2 + scaledHeight / 2
        let originalX = originalSize.width * (scaledX / scaledWidth)
        let originalY = originalSize.height * (scaledY / scaledHeight)
        return CGRect(x: originalX, y: originalY, width: originalWidth, height: originalHeight)
    }
    
    private func ocrReading(image: CGImage) async -> String {
        let ocr = SRTScraperOCR()
        let texts = await ocr.scrapImage(image)
        return texts.joined(separator: " ")
    }
    
    private var lastSubtitle: Subtitle?
    
    @MainActor
    private func addToSubtitle(text: String, startTime: CMTime, endTime: CMTime) {
        subtitles.append(Subtitle(text: text, startTime: startTime, endTime: endTime))
    }
    
    @MainActor
    private func setToTime(time: CMTime) {
        self.videoPlayer?.seek(to: time)
    }
    
    func requestPushNotification() async throws {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
    }
    
    private func sendPushNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Subtitle Generate Success"
        content.subtitle = "\(title)"

        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
    }
}

enum SRTScraperError: Error {
    case cropImageError
    case missingVideoError
    case frameGeneratorError
}

struct Subtitle: Identifiable {
    
    var id: CMTime {
        return startTime
    }
    
    var text: String
    var startTime: CMTime
    var endTime: CMTime
}
