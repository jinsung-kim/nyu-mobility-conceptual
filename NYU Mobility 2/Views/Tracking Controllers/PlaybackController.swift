//
//  PlaybackController.swift
//  NYU Mobility 2
//
//  Created by Jin Kim on 8/10/20.
//  Copyright © 2020 Jin Kim. All rights reserved.
//

import UIKit
import AVFoundation

class PlaybackController: UIViewController {
    
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!

    var videoURL: URL!
    
    @IBOutlet weak var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Screen will not go to sleep with this line below
        UIApplication.shared.isIdleTimerDisabled = true
        
        shareVideoButton()
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = view.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoView.layer.insertSublayer(avPlayerLayer, at: 0)
        
        view.layoutIfNeeded()
        
        let playerItem = AVPlayerItem(url: videoURL!)
        avPlayer.replaceCurrentItem(with: playerItem)
        
        avPlayer.play()
    }
    
    // Upper right item from the tracking controller that goes to send the video off
    func shareVideoButton() {
        let instructionButton = UIBarButtonItem()
        instructionButton.title = "Share"
        instructionButton.action = #selector(sessionsTap)
        instructionButton.target = self
        navigationItem.rightBarButtonItem = instructionButton
    }
    
    @objc func sessionsTap() {
        performSegue(withIdentifier: "ShareVideo", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.destination is ShareVideoController) {
            let vc = segue.destination as? ShareVideoController
            vc?.videoURL = self.videoURL
        }
    }
    
}
