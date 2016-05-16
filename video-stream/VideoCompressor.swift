//
//  VideoCompressor.swift
//  video-stream
//
//  Created by Rplay on 14/05/16.
//  Copyright © 2016 rplay. All rights reserved.
//

import Foundation

class VideoCompressor {
    
    let ffmpegWrapper: FFmpegWrapper = FFmpegWrapper()
    let videoUploader: VideoUploader = VideoUploader()
    let writer = VideoWriter.sharedInstance.writer
    let writerInputVideo = VideoWriter.sharedInstance.writerInputVideo
    let writerInputAudio = VideoWriter.sharedInstance.writerInputAudio
    
    var URLServer = Streamer.sharedInstance.URLServer
    
    func compress(inputPath: String, outputPath: String, videoToWriteIndex: Int) {
        
        if writer?.status == .Writing {
            writerInputVideo?.markAsFinished()
            writerInputAudio?.markAsFinished()
            //let outputUrl = avAssetWriter.outputURL
            writer?.finishWritingWithCompletionHandler { () -> Void in
                //let documentsDirectoryUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last
                //let tsFileUrl = documentsDirectoryUrl?.URLByAppendingPathComponent("master\(videoToWriteIndex).ts")
                print("Input: \(inputPath)")
                print("Output: \(outputPath)")
                self.ffmpegWrapper.convertInputPath(inputPath, outputPath: outputPath, options: nil,
                    progressBlock: { (a: UInt, b: UInt64, c: UInt64) -> Void in print("a: \(a), \(b), \(c)") },
                    completionBlock: { (succeeded: Bool, b: NSError!) -> Void in
                        print("Bool: \(succeeded)\n Error: \(b)")
                        if succeeded {
                            //self.dispatch_async_custom();
                            self.videoUploader.upload(outputPath, URLToUpload: self.URLServer!)
                        }
                })
            }
        }
        
    }
}