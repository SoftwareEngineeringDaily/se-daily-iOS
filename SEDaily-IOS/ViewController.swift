//
//  ViewController.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 7/22/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    /// An array of `Asset` objects representing the m4a files used for playback in this sample.
    var assets = [Asset]()
    
    /// The instance of `AssetPlaybackManager` to use for playing an `Asset`.
    var assetPlaybackManager: Manager!
    
    var remoteCommandManager: RemoteCommandManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        guard let url = Bundle.main.url(forResource: "Song 1", withExtension: "m4a") else {
//            log.error("Error")
//            return
//        }
        
        guard let url = URL(string: "http://traffic.libsyn.com/sedaily/ReinforcementLearning.mp3?_=1") else {
            log.error("Error")
            return
        }
        let asset = Asset(assetName: "HERE", urlAsset: AVURLAsset(url: url))
        self.assetPlaybackManager =  Manager()
        assetPlaybackManager.asset = asset
        
        // Initializer the `RemoteCommandManager`.
        remoteCommandManager = RemoteCommandManager(assetPlaybackManager: assetPlaybackManager)
        
        // Always enable playback commands in MPRemoteCommandCenter.
        remoteCommandManager.activatePlaybackCommands(true)
        remoteCommandManager.toggleSkipForwardCommand(true, interval: 10)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
