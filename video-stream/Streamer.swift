//
//  Streamer.swift
//  video-stream
//
//  Created by Rplay on 14/05/16.
//  Copyright © 2016 rplay. All rights reserved.
//

import Foundation
import AVFoundation

class Streamer {
    
    var timer: NSTimer?
    var videoWriter: VideoWriter?
    var fileName: String?
    var index: Int?
    var URLServer: String?
    
    let videoCompressor = VideoCompressor()
    static let sharedInstance = Streamer()
    
    func startStreaming(URLServer: String, UploadVideoEvery: Double, session: AVCaptureSession, fileName: String){
        self.fileName = fileName
        self.URLServer = URLServer
        index = 0
        videoWriter = VideoWriter.sharedInstance
        videoWriter?.setup()
        videoWriter?.startWriting()
        session.startRunning()
        timer = NSTimer.scheduledTimerWithTimeInterval(UploadVideoEvery, target: self, selector: Selector("compressAndSend"), userInfo: nil, repeats: true)
    }
    
    func stopStreaming(){
        timer?.invalidate()
    }
    
    func compressAndSend(){
        let documentsDirectoryUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last
        let tsFileUrl = documentsDirectoryUrl?.URLByAppendingPathComponent("\(self.fileName! + String(index)).ts")
        videoCompressor.compress(videoWriter!.writer!.outputURL.path!, outputPath: tsFileUrl!.path!, videoToWriteIndex: index!)
    }
}