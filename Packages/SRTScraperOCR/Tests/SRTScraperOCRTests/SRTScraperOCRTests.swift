import XCTest
import AppKit
@testable import SRTScraperOCR

final class SRTScraperOCRTests: XCTestCase {
    
    private var ocrReader: SRTScraperOCR!
    
    func testOCR() {
        let bundle = Bundle.module
        guard let imagePath = bundle.path(forResource: "testImage", ofType: "png", inDirectory: "Resources") else {
            XCTFail("Image not found")
            return
        }
        
        ocrReader = SRTScraperOCR(completionHandler: { texts in
            for text in texts {
                XCTAssert(text.contains("原产地名称"))
            }
        })
        
        
        if let image = NSImage(contentsOfFile: imagePath),
           let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            ocrReader.scrapImage(cgImage)
        } else {
            XCTFail("Failed to load image")
        }
    }
}
