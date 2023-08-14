import CoreGraphics
import Vision

public struct SRTScraperOCR {

    public init() {
        
    }
    
    public func scrapImage(_ image: CGImage, completionHandler: @escaping ([String]) -> Void) {
        
        let requestHandler = VNImageRequestHandler(cgImage: image)
        
        // Create a new request to recognize text.
        let request = VNRecognizeTextRequest { request, error in
            guard let observations =
                    request.results as? [VNRecognizedTextObservation] else {
                return
            }
            let recognizedStrings = observations.compactMap { observation in
                // Return the string of the top VNRecognizedText instance.
                return observation.topCandidates(1).first?.string
            }
            
            // Process the recognized strings.
            completionHandler(recognizedStrings)
        }
        request.recognitionLanguages = ["zh"]
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        do {
            // Perform the text-recognition request.
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }
    
    
    public func scrapImage(_ image: CGImage) async -> [String] {
        await withCheckedContinuation { continuation in
            scrapImage(image) { texts in
                continuation.resume(returning: texts)
            }
        }
    }
}
