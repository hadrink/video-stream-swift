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
    var streamer: Streamer?

    @IBOutlet var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        session = Session()
        preview = Preview()
        streamer = Streamer.sharedInstance
        
        let sessionAudioVideo = session?.createSession()
        let previewSize = self.view.frame.size
        let previewAudioVideo = preview?.createPreview(previewSize, session: sessionAudioVideo!)
        
        mainView.layer.addSublayer(previewAudioVideo!)
        
        streamer?.startStreaming("https://castproject.herokuapp.com/stream-test", UploadVideoEvery: 10.0, session: session!.session!, fileName: "test")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //-- Create Session

}

