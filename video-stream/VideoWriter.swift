//
//  VideoWriter.swift
//  video-stream
//
//  Created by Rplay on 13/05/16.
//  Copyright © 2016 rplay. All rights reserved.
//

import Foundation
import AVFoundation

class VideoWriter {
    
    static let sharedInstance = VideoWriter()
    
    var writer: AVAssetWriter?
    var writerInput: AVAssetWriterInput?
    var index = 0
    
    func setup() {
        let cacheDirectoryURL = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).last
        let saveFileURL = cacheDirectoryURL?.URLByAppendingPathComponent("capture\(index).mp4")
        
        print(saveFileURL)
        
        if NSFileManager.defaultManager().fileExistsAtPath(saveFileURL!.path!) {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(saveFileURL!)
            } catch _ {
            }
        }
        
        writer = try? AVAssetWriter(URL: saveFileURL!, fileType: AVFileTypeQuickTimeMovie)
        writerInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264,
                                                                                       AVVideoWidthKey : 240,
                                                                                       AVVideoHeightKey: 240])
        writerInput?.expectsMediaDataInRealTime = true
        writer?.addInput(writerInput!)
        // 10 frames per second
        writer?.movieFragmentInterval = CMTimeMakeWithSeconds(10, 600)
        self.startWriting()
        
        //writer?.startWriting()
        //writer.startSessionAtSourceTime(CMTimeMakeWithSeconds(10, 600))
    }
    
    func startWriting() {
        writer?.startWriting()
        writer?.startSessionAtSourceTime(CMTimeMakeWithSeconds(10, 600))
    }
    
}