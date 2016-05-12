//
//  createSession.swift
//  video-stream
//
//  Created by Rplay on 12/05/16.
//  Copyright © 2016 rplay. All rights reserved.
//

import Foundation
import AVFoundation

class session: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    var session: AVCaptureSession?
    var sessionQueue: dispatch_queue_t?
    var inputVideo: AVCaptureDeviceInput?
    var inputAudio: AVCaptureDeviceInput?
    var outputVideo: AVCaptureVideoDataOutput?
    var outputAudio: AVCaptureAudioDataOutput?
    
    let deviceSettings = DeviceSettings()
    
    func createSession() -> AVCaptureSession {
        sessionQueue = dispatch_queue_create("cameraQueue", DISPATCH_QUEUE_SERIAL)
        session = AVCaptureSession()
        session?.sessionPreset = AVCaptureSessionPreset352x288
        
        addVideoInput()
        addAudioInput()
        
        addVideoOutput()
        addAudioOutput()
        
        return session!
    }
    
    func addVideoInput() {
        
        let deviceVideo = deviceSettings.getVideoDevice()
        var addInputVideoError: NSError? = nil
        
        do {
            try inputVideo = AVCaptureDeviceInput(device: deviceVideo)
        } catch let err as NSError {
            addInputVideoError = err
        }
        
        if addInputVideoError == nil {
            session?.addInput(inputVideo)
        } else {
            print("camera input error: \(addInputVideoError)")
        }

    }
    
    func addAudioInput() {
        
        let deviceAudio = deviceSettings.getAudioDevice()
        var addInputAudioError: NSError?
        
        do {
            let inputAudio = try AVCaptureDeviceInput(device: deviceAudio)
            session?.addInput(audioInput)
        } catch let err as NSError {
            addInputAudioError = err
            print(addInputAudioError)
        }
    }
    
    func addVideoOutput() {
        outputVideo = AVCaptureVideoDataOutput()
        outputVideo?.alwaysDiscardsLateVideoFrames = true
        outputVideo?.setSampleBufferDelegate(self, queue: sessionQueue)
        
        if session!.canAddOutput(outputVideo) {
            session!.addOutput(outputVideo)
        }
    }
    
    
    func addAudioOutput() {
        outputAudio = AVCaptureAudioDataOutput()
        outputAudio?.setSampleBufferDelegate(self, queue: sessionQueue)
        
        if session!.canAddOutput(outputAudio) {
            session!.addOutput(outputAudio)
        }
    }
    
    func startSession() {
        let session = createSession()
        session.startRunning()
    }
}

