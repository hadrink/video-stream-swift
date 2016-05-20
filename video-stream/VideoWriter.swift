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
    var streamer = Streamer.sharedInstance
    var bufferVideoLate: [CMSampleBuffer] = []
    var bufferAudioLate: [CMSampleBuffer] = []
    
    var isStart:Bool?
    
    func setup() {
        
        print("SETUP")
        let index = Streamer.sharedInstance.index
        
        print("Index\(index)")
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
        writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : 240, AVVideoHeightKey: 320])
        writerInputVideo?.expectsMediaDataInRealTime = true
        writerInputVideo?.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2))
        
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
        writer?.movieFragmentInterval = CMTimeMakeWithSeconds(streamer.readingTime! , 600)
        
    }
    
    func startWriting() {
        writer?.startWriting()
        writer?.startSessionAtSourceTime(CMTimeMakeWithSeconds(streamer.readingTime! , 600))
        isStart = true
    }
    
    func write(sampleBuffer: CMSampleBuffer) {
        
        if isStart! {
            if CMSampleBufferGetImageBuffer(sampleBuffer) != nil {
                if writerInputVideo!.readyForMoreMediaData {
                    for buffer in bufferVideoLate {
                        writerInputVideo?.appendSampleBuffer(buffer)
                    }
                    bufferVideoLate.removeAll()
                    writerInputVideo?.appendSampleBuffer(sampleBuffer)
                }
            } else if CMSampleBufferGetDataBuffer(sampleBuffer) != nil {
                if writerInputAudio!.readyForMoreMediaData {
                    for buffer in bufferAudioLate {
                        writerInputAudio?.appendSampleBuffer(buffer)
                    }
                    bufferAudioLate.removeAll()
                    writerInputAudio?.appendSampleBuffer(sampleBuffer)
                }
            }
            
            let status = writer!.status
            //let error = writer?.error
            switch status {
            case .Unknown:
                print("Unknown")
                if CMSampleBufferGetImageBuffer(sampleBuffer) != nil {
                    bufferVideoLate.append(sampleBuffer)
                } else {
                    bufferAudioLate.append(sampleBuffer)
                }
            case .Writing:
                print("Writing")
            case .Completed:
                print("Completed")
            case .Failed:
                print("Failed")
            case .Cancelled:
                print("Cancelled")
            }
        }
    }
    
    func restartWriting(){
        let index = Streamer.sharedInstance.index
        Streamer.sharedInstance.index = index! + 1
        print("INDEX \(index!)")
        setup()
        startWriting()
        //streamer.session?.startRunning()
    }
}