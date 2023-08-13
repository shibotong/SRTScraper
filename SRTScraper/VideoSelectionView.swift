//
//  VideoSelectionView.swift
//  SRTScraper
//
//  Created by Shibo Tong on 12/8/2023.
//

import SwiftUI
import ResizableRectangle
import AVKit

struct VideoSelectionView: View {
    
    @Binding var selectionRect: CGRect
    
    let videoPlayer: AVPlayer?
    
    private let width: CGFloat = 640
    private let height: CGFloat = 360
    
    var body: some View {
        playerScreen
            .frame(width: width, height: height)
    }
    
    private var playerScreen: some View {
        ZStack {
            if let videoPlayer {
                VideoPlayer(player: videoPlayer)
                    .overlay {
                            ResizableRectangle(rect: $selectionRect, max: CGSize(width: width, height: height))
                    }
            } else {
                Text("Open a Video")
            }
        }
    }
}

struct VideoSelectionView_Previews: PreviewProvider {
    
    @State static var rect: CGRect = CGRect(x: 0, y: 0, width: 100, height: 100)
    
    static var previews: some View {
        VideoSelectionView(selectionRect: $rect, videoPlayer: nil)
    }
}
