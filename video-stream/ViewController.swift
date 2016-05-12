//
//  ViewController.swift
//  video-stream
//
//  Created by Rplay on 12/05/16.
//  Copyright © 2016 rplay. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var avAssetWriter: AVAssetWriter!
    var avAssetWriterInput: AVAssetWriterInput!
    var captureSession: AVCaptureSession!
    var input: AVCaptureDeviceInput!
    var captureDevice: AVCaptureDevice!
    var output: AVCaptureVideoDataOutput!
    var currentIndex: Int!
    var maxTimer: NSTimer!
    var ffmpegWrapper: FFmpegWrapper!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //-- Create Session
    
    func createSession() {
        
        //-- Dispatch work in a specific queue
        _sessionQueue = dispatch_queue_create("cameraQueue", DISPATCH_QUEUE_SERIAL)
        
        //-- Declare session
        _session = AVCaptureSession()
        
        _session?.sessionPreset = AVCaptureSessionPreset352x288
        
        //-- Choose video media
        _device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        do {
            try _device?.lockForConfiguration()
            _device?.activeVideoMinFrameDuration = CMTimeMake(1, 10)
            _device?.activeVideoMaxFrameDuration = CMTimeMake(1, 5)
        } catch let err as NSError {
            print(err)
        }
        
        _device?.unlockForConfiguration()
        
        //-- Check if everything is OK
        var error: NSError? = nil
        do {
            try _input = AVCaptureDeviceInput(device: _device)
        } catch let err as NSError {
            error = err
        }
        
        if error == nil {
            _session?.addInput(_input)
        } else {
            print("camera input error: \(error)")
        }
        
        
        
        var audioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
        
        
        do {
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            _session?.addInput(audioInput)
        } catch let err as NSError {
            error = err
        }
        
        //-- Load the preview
        _prevLayer = AVCaptureVideoPreviewLayer(session: _session)
        _prevLayer?.frame.size = myView.frame.size
        _prevLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        _prevLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
        
        //-- Add preview in layer
        myView.layer.addSublayer(_prevLayer!)
        
        //-- Let's go
        _session?.startRunning()
    }



}

