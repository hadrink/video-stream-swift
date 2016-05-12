//
//  DeviceSettings.swift
//  video-stream
//
//  Created by Kévin Rignault on 12/05/2016.
//  Copyright © 2016 kevinrignault. All rights reserved.
//

import Foundation
import AVFoundation

class DeviceSettings {
    
    //MARK: Variables
    
    var captureDevice: AVCaptureDevice!
    
    
    //MARK: Functions

    func getDevice() -> AVCaptureDevice {
        return captureDevice
    }

    func configureDevice() {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
            } catch _ {
                print("Device KO");
            }
            //-- Lock focus
            device.focusMode = .Locked
            //-- 1/20 of a second i.e 0.05seconds interval between frame
            device.activeVideoMinFrameDuration = CMTimeMake(1, 20)
            //--
            device.unlockForConfiguration()
        }
    }
    
}