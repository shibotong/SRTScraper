import AVKit
import CoreMedia

public struct VideoFrameExtractor {
    
    public var frame: CMTime?
    public var video: AVAsset
    public var frames: [CMTime] = []

    public init(video: AVAsset) {
        self.video = video
    }
    
    public func generateImage() async throws -> (CGImage, CMTime) {
        guard let frame else {
            throw VideoFrameExtratorError.noFrame
        }
        let generator = AVAssetImageGenerator(asset: video)
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        let (image, time) = try await generator.image(at: frame)
        return (image, time)
    }
    
    public func generateImages() -> AVAssetImageGenerator.Images {
        let generator = AVAssetImageGenerator(asset: video)
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        let images = generator.images(for: frames)
        return images
    }
}

enum VideoFrameExtratorError: Error {
    case noFrame
}
