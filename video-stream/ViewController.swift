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


}

