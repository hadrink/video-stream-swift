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
    var index = Streamer.sharedInstance.index
    var streamer = Streamer.sharedInstance
    
    
    func upload(videoToUpload: String, URLToUpload: String) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            //var urlString = "\(self.endpointUrlString)/master\(self.currentIndex).ts/"
            //var urlString = "http://vps224869.ovh.net/cast/put.php?filename=master\(self.currentIndex).ts"
            print("URL TO UPLOAD: \(URLToUpload)\(self.streamer.fileName!)\(self.index!).ts/")
            let fileToSend = "\(self.streamer.fileName!)\(self.index!).ts/"
            let request = NSMutableURLRequest(URL: NSURL(string: URLToUpload+fileToSend)!)
            
            request.HTTPMethod = "PUT"
            let videoURL = NSURL(fileURLWithPath: videoToUpload)
            let tsData = NSData(contentsOfURL: videoURL)
            request.HTTPBody = tsData
            if nil != tsData {
                NSURLSession.sharedSession().uploadTaskWithRequest(request, fromData: tsData,
                    completionHandler: { (responseData: NSData?, response: NSURLResponse?, responseError: NSError?) -> Void in
                        print("END REQUEST TS FILE")
                        self.updateM3U8File(responseData, response: response, responseError: responseError, URLToUpload: URLToUpload)
                }).resume() //handler
            } else {
                print("No data")
            }
        })
        //restartWriting()
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
            var m3u8String = "#EXTM3U\n#EXT-X-TARGETDURATION:10\n#EXT-X-VERSION:3\n#EXT-X-MEDIA-SEQUENCE:\(index!)\n"
            
            if index! - 2 >= 0 {
                m3u8String += "#EXTINT:10.0,\n"
                m3u8String += "\(self.streamer.fileName!)\(index! - 2).ts\n"
            }
            
            if index! - 1 >= 0 {
                m3u8String += "#EXTINT:10.0,\n"
                m3u8String += "\(self.streamer.fileName!)\(index! - 1).ts\n"
            }
            
            m3u8String += "#EXTINT:10.0,\n"
            m3u8String += "\(self.streamer.fileName!)\(index!).ts\n"
            
            //var playlistUrlString = "\(self.endpointUrlString)?filename=master.m3u8"
            let fileToSend = "\(self.streamer.fileName!).m3u8/"
            var playlistUrlString = URLToUpload+fileToSend
            print("URL M3U8 \(playlistUrlString)")
            let playlistRequest = NSMutableURLRequest(URL: NSURL(string: playlistUrlString)!)
            playlistRequest.HTTPMethod = "PUT"
            let playlistData = m3u8String.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            playlistRequest.HTTPBody = playlistData
            
            NSURLSession.sharedSession().uploadTaskWithRequest(playlistRequest, fromData: playlistData, completionHandler: { (playlistResponseData: NSData?, playlistResponse: NSURLResponse?, playlistError: NSError?) -> Void in
                if responseData != nil {
                    let responseString = NSString(data: responseData, encoding: NSUTF8StringEncoding)
                    if responseString != nil {
                        print(responseString)
                    }
                }
                if responseError != nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in print("\(responseError.localizedDescription)") })
                } else {
                    print("END REQUEST M3U8 FILE")
                }
            }).resume() // completionHandler
            
        } //else
    }
    
    /*func restartWriting(){
        Streamer.sharedInstance.index = self.index! + 1
        self.videoWriter.setup()
        self.videoWriter.startWriting()
        self.streamer.session?.startRunning()
    }*/
}