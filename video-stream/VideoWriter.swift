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
    var writerInputVideo: AVAssetWriterInput?
    var writerInputAudio: AVAssetWriterInput?
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
        writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264,
                                                                                       AVVideoWidthKey : 240,
                                                                                       AVVideoHeightKey: 240])
        writerInputVideo?.expectsMediaDataInRealTime = true
        
        let audioOutputSettings: Dictionary<String, AnyObject> = [
            AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
            AVNumberOfChannelsKey : 2,
            AVSampleRateKey : 44100
            //AVEncoderBitRateKey : 128000
        ]
        
        writerInputAudio = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: audioOutputSettings)
        
        writerInputAudio?.expectsMediaDataInRealTime = true
        
        writer?.addInput(writerInputVideo!)
        writer?.addInput(writerInputAudio!)
        
        print("Output URL: \(writer?.outputURL)")
        // 10 frames per second
        writer?.movieFragmentInterval = CMTimeMakeWithSeconds(10, 600)
        //self.startWriting()
        
        //writer?.startWriting()
        //writer.startSessionAtSourceTime(CMTimeMakeWithSeconds(10, 600))
    }
    
    func startWriting() {
        writer?.startWriting()
        writer?.startSessionAtSourceTime(CMTimeMakeWithSeconds(10, 600))
    }
    
}