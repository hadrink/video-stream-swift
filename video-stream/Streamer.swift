//
//  Streamer.swift
//  video-stream
//
//  Created by Rplay on 14/05/16.
//  Copyright © 2016 rplay. All rights reserved.
//

import Foundation
import AVFoundation

class Streamer: NSObject {
    
    static let sharedInstance = Streamer()
    
    var timer: NSTimer?
    var videoWriter: VideoWriter?
    var fileName: String?
    var index: Int?
    var URLServer: String?
    var session: AVCaptureSession?
    var videoCompressor: VideoCompressor?
    var clearCache: ClearCache?
    var readingTime:Double?
    
    func startStreaming(URLServer: String, UploadVideoEvery: Double, session: AVCaptureSession, fileName: String) {
        self.readingTime = UploadVideoEvery
        self.fileName = fileName
        self.URLServer = URLServer
        self.session = session
        index = 0
        clearCache = ClearCache()
        videoWriter = VideoWriter.sharedInstance
        videoWriter?.setup()
        videoWriter?.startWriting()
        self.session?.startRunning()
        timer = NSTimer.scheduledTimerWithTimeInterval(UploadVideoEvery, target: self, selector: Selector("compressAndSend"), userInfo: nil, repeats: true)
    }
    
    func stopStreaming(){
        timer?.invalidate()
    }
    
    func compressAndSend(){
        let documentsDirectoryUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last
        let tsFileUrl = documentsDirectoryUrl?.URLByAppendingPathComponent("\(self.fileName! + String(index!)).ts")
        videoCompressor = VideoCompressor()
        self.videoCompressor?.compress(videoWriter!.writer!.outputURL.path!, outputPath: tsFileUrl!.path!, videoToWriteIndex: index!)
    }
    
}