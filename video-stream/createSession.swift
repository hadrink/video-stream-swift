//
//  createSession.swift
//  video-stream
//
//  Created by Rplay on 12/05/16.
//  Copyright © 2016 rplay. All rights reserved.
//

import Foundation
import AVFoundation

class session {
    
    var session: AVCaptureSession?
    var sessionQueue: dispatch_queue_t?
    var inputVideo: AVCaptureDeviceInput?
    var inputAudio: AVCaptureDeviceInput?
    var outputVideo: AVCaptureVideoDataOutput?
    var outputAudio: AVCaptureVideoDataOutput?
    
    func createSession() -> AVCaptureSession {
        sessionQueue = dispatch_queue_create("cameraQueue", DISPATCH_QUEUE_SERIAL)
        session = AVCaptureSession()
        session?.sessionPreset = AVCaptureSessionPreset352x288
        return session!
    }
    
    func addVideoInput() {
        
    }
    
    func addAudioInput() {
        
        let deviceSettings = DeviceSettings()
        let device = deviceSettings.getDevice()
        
        do {
            let inputAudio = try AVCaptureDeviceInput(device: audioDevice)
            _session?.addInput(audioInput)
        } catch let err as NSError {
            error = err
        }
    }
    
    func addVideoOutput() {
        
    }
    
    func addAudioOutput() {
        
    }
    
    func startSession() {
        let session = createSession()
        session.startRunning()
    }
}

