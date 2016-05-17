//
//  VideoUploader.swift
//  video-stream
//
//  Created by Rplay on 14/05/16.
//  Copyright © 2016 rplay. All rights reserved.
//

import Foundation

class VideoUploader {
    
    var videoWriter = VideoWriter.sharedInstance
    var index = VideoWriter.sharedInstance.index
    var streamer = Streamer.sharedInstance
    
    
    func upload(videoToUpload: String, URLToUpload: String) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            //var urlString = "\(self.endpointUrlString)/master\(self.currentIndex).ts/"
            //var urlString = "http://vps224869.ovh.net/cast/put.php?filename=master\(self.currentIndex).ts"
            print("URL TO UPLOAD: \(URLToUpload)\(self.streamer.fileName!)\(self.index!).ts/")
            let fileToSend = "\(self.streamer.fileName!)\(self.index).ts/"
            let request = NSMutableURLRequest(URL: NSURL(string: URLToUpload+fileToSend)!)
            
            request.HTTPMethod = "PUT"
            let videoURL = NSURL(fileURLWithPath: videoToUpload)
            let tsData = NSData(contentsOfURL: videoURL)
            request.HTTPBody = tsData
            if nil != tsData {
                NSURLSession.sharedSession().uploadTaskWithRequest(request, fromData: tsData,
                    completionHandler: { (responseData: NSData?, response: NSURLResponse?, responseError: NSError?) -> Void in
                        self.updateM3U8File(responseData, response: response, responseError: responseError, URLToUpload: URLToUpload)
                }).resume() //handler
            } else {
                print("No data")
            }
        })
    }
    
    func updateM3U8File(responseData: NSData!, response: NSURLResponse!, responseError: NSError!, URLToUpload: String) {
        if responseData != nil {
            let responseString = NSString(data: responseData, encoding: NSUTF8StringEncoding)
            if responseString != nil {
                print(responseString)
            }
        }
        if responseError != nil {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in print("\(responseError.localizedDescription)") })
        } else {
            var m3u8String = "#EXTM3U\n#EXT-X-TARGETDURATION:10\n#EXT-X-VERSION:3\n#EXT-X-MEDIA-SEQUENCE:\(index)\n"
            
            if index! - 2 >= 0 {
                m3u8String += "#EXTINT:10.0,\n"
                m3u8String += "master\(index).ts\n"
            }
            
            if index! - 1 >= 0 {
                m3u8String += "#EXTINT:10.0,\n"
                m3u8String += "master\(index).ts\n"
            }
            
            m3u8String += "#EXTINT:10.0,\n"
            m3u8String += "master\(index).ts\n"
            
            //var playlistUrlString = "\(self.endpointUrlString)?filename=master.m3u8"
            let fileToSend = "\(self.streamer.fileName!).m3u8/"
            var playlistUrlString = URLToUpload+fileToSend
            print("URL M3U8 \(playlistUrlString)")
            let playlistRequest = NSMutableURLRequest(URL: NSURL(string: playlistUrlString)!)
            playlistRequest.HTTPMethod = "PUT"
            let playlistData = m3u8String.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            playlistRequest.HTTPBody = playlistData
            
            NSURLSession.sharedSession().uploadTaskWithRequest(playlistRequest, fromData: playlistData,
                                                               completionHandler: { (playlistResponseData: NSData?, playlistResponse: NSURLResponse?, playlistError: NSError?) -> Void in
                                                                if responseData != nil {
                                                                    let responseString = NSString(data: responseData, encoding: NSUTF8StringEncoding)
                                                                    if responseString != nil {
                                                                        print(responseString)
                                                                    }
                                                                }
                                                                if responseError != nil {
                                                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in print("\(responseError.localizedDescription)") })
                                                                } else {
                                                                    //self.currentIndex = self.currentIndex + 1
                                                                    VideoWriter.sharedInstance.index = VideoWriter.sharedInstance.index! + 1
                                                                    
                                                                    /*let cacheDirectoryURL = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).last
                                                                    let saveFileURL = cacheDirectoryURL?.URLByAppendingPathComponent("capture\(self.currentIndex).mp4")
                                                                    if NSFileManager.defaultManager().fileExistsAtPath(saveFileURL!.path!) {
                                                                        do {
                                                                            try NSFileManager.defaultManager().removeItemAtURL(saveFileURL!)
                                                                        } catch _ {
                                                                        }
                                                                    }
                                                                    
                                                                    self.avAssetWriter = try? AVAssetWriter(URL: saveFileURL!, fileType: AVFileTypeQuickTimeMovie)
                                                                    self.avAssetWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo,
                                                                        outputSettings: [AVVideoCodecKey:AVVideoCodecH264,       AVVideoWidthKey: 240,
                                                                            AVVideoHeightKey: 240])
                                                                    self.avAssetWriterInput.expectsMediaDataInRealTime = true
                                                                    self.avAssetWriter.addInput(self.avAssetWriterInput)
                                                                    self.avAssetWriter.movieFragmentInterval = CMTimeMakeWithSeconds(5, 600)
                                                                    
                                                                    self.avAssetWriter.startWriting()
                                                                    self.avAssetWriter.startSessionAtSourceTime(CMTimeMakeWithSeconds(5, 600))
                                                                    self.captureSession.startRunning()*/
                                                                    self.videoWriter.setup()
                                                                    self.videoWriter.startWriting()
                                                                    self.streamer.session?.startRunning()
                                                                }
            }).resume() // completionHandler
        } //else
    }
}