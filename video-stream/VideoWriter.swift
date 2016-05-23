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
    var bandwidth: Double = 0.0
    
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
        //writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : 240, AVVideoHeightKey: 320])
        let quality = defineQuality(streamer.session!)
        videoQuality(self.bandwidth, videoSize: quality)
        writerInputVideo?.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2.0))
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
        writer?.movieFragmentInterval = CMTimeMakeWithSeconds(10 , 600)
        
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
    
    func videoQuality(bandwidth: Double, videoSize: CGSize) {
        print("Bandwidth: \(bandwidth) kb/s")
        
        let ultraHD: CGSize = CGSize(width: 3840, height: 2160)
        let fullHD: CGSize = CGSize(width: 1920, height: 1080)
        let HD: CGSize = CGSize(width: 1280, height: 720)
        let mediumQuality: CGSize = CGSize(width: 640, height: 480)
        let lowQuality: CGSize = CGSize(width: 352, height: 288)
        
        let compressionProperties: NSDictionary = [AVVideoExpectedSourceFrameRateKey : 10,
                                                   AVVideoMaxKeyFrameIntervalDurationKey : 10,
                                                   AVVideoAverageBitRateKey: 50 * 1000
                                                   
        ]
        
        switch videoSize {
        case ultraHD:
            print("ultraHD")
            switch bandwidth {
                case 0..<150:
                    writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : 240, AVVideoHeightKey: 420])
                    break
                case 150..<300:
                    writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : 360, AVVideoHeightKey: 640])
                    break
                case 300..<600:
                    writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : 540, AVVideoHeightKey: 960])
                    break
                case 600..<1000:
                    writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : 720, AVVideoHeightKey: 1280])
                    break
                case 1000..<100000000:
                    writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : 1080, AVVideoHeightKey: 1920])
                    break
                default:
                    writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : 240, AVVideoHeightKey: 420])
                    break
            }
        case fullHD:
            print("fullHD")
            switch bandwidth {
            case 0..<150:
                writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : 240, AVVideoHeightKey: 420])
                break
            case 150..<300:
                writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : 360, AVVideoHeightKey: 640])
                break
            case 300..<600:
                writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : 540, AVVideoHeightKey: 960])
                break
            case 600..<1000:
                writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : 720, AVVideoHeightKey: 1280])
                break
            case 1000..<100000000:
                writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : 1080, AVVideoHeightKey: 1920])
                break
            default:
                writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : 240, AVVideoHeightKey: 420])
                break
            }
        case HD:
            print("HD")
            switch bandwidth {
            case 0..<150:
                writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : 240, AVVideoHeightKey: 420])
                break
            case 150..<300:
                writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : 360, AVVideoHeightKey: 640])
                break
            case 300..<600:
                writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : 540, AVVideoHeightKey: 960])
                break
            case 600..<100000000:
                writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : 720, AVVideoHeightKey: 1280])
                break
            default:
                writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : 240, AVVideoHeightKey: 420])
                break
            }
        case mediumQuality:
            print("mediumQuality")
            switch bandwidth {
            case 0..<200:
                writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : 240, AVVideoHeightKey: 320, AVVideoCompressionPropertiesKey: compressionProperties])
                break
            case 200..<100000000:
                writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : 480, AVVideoHeightKey: 640, AVVideoCompressionPropertiesKey: compressionProperties])
                break
            default:
                writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : 240, AVVideoHeightKey: 320, AVVideoCompressionPropertiesKey: compressionProperties])
                break
            }
        case lowQuality:
            print("lowQuality")
            switch bandwidth {
            case 0..<150:
                writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : 240, AVVideoHeightKey: 293])
                break
            case 150..<100000000:
                writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : 288, AVVideoHeightKey: 352])
                break
            default:
                writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : 240, AVVideoHeightKey: 293])
                break
            }
        default: writerInputVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : 240, AVVideoHeightKey: 420])
        }
        
    }
    
    func defineQuality(session: AVCaptureSession) -> CGSize {
        let preset = session.sessionPreset
        var size: CGSize?
        
        switch preset {
            case AVCaptureSessionPreset352x288: size = CGSize(width: 352, height: 288); break
            case AVCaptureSessionPreset640x480: size = CGSize(width: 640, height: 480); break
            case AVCaptureSessionPreset1280x720: size = CGSize(width: 1280, height: 720); break
            case AVCaptureSessionPreset1920x1080: size = CGSize(width: 1920, height: 1080); break
            case AVCaptureSessionPreset3840x2160: size = CGSize(width: 3840, height: 2160); break
            default: size = CGSize(width: 1920, height: 1080)
        }
        
        return size!
    }
}