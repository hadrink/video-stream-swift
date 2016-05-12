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
    
    var session: Session?
    var preview: Preview?
    
    var ffmpegWrapper: FFmpegWrapper!

    @IBOutlet var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        session = Session()
        preview = Preview()
        
        let sessionAudioVideo = session?.createSession()
        let previewAudioVideo = preview?.createPreview(self.view.frame.size, session: sessionAudioVideo!)
        
        mainView.layer.addSublayer(previewAudioVideo!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //-- Create Session

}

