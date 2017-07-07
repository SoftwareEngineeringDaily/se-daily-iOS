//
//  AudioManager.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/29/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation
import AVFoundation
import Alamofire

class AudioManager {
    static let shared: AudioManager = AudioManager()
    private init() {}
    
//    var podcastModel: PodcastModel!
    var request: Alamofire.Request?
    var audioPlayer: AVAudioPlayer!
    
    func playAudio() {
        if self.isPlaying() {
            audioPlayer.stop()
        }
        
        if request != nil {
            request?.resume()
            return
        }
        AudioViewManager.shared.stopActivityIndicator()
        
        guard audioPlayer != nil else { return }
        audioPlayer.play()
        NotificationCenter.default.post(name: .playingAudio, object: nil)
    }
    
    func pauseAudio() {
        if request != nil {
            request?.suspend()
            return
        }
        
        guard audioPlayer != nil else { return }
        log.info(audioPlayer.currentTime)
        audioPlayer.pause()
        NotificationCenter.default.post(name: .playingAudio, object: nil)
    }
    
    func stopAudio() {
        if request != nil {
            request?.cancel()
            //@TODO: cancel audio if playing?
            return
        }
        
        AudioViewManager.shared.stopActivityIndicator()
        
        guard audioPlayer != nil else { return }
        audioPlayer.stop()
        audioPlayer = nil
    }
    
    func loadAudio(model: PodcastModel) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        } catch let error {
            log.error(error.localizedDescription)
        }
        
        if model.mp3Saved == true {
            self.setSound(url: model.getMP3URL())
            AudioViewManager.shared.setText(text: model.podcastName!)
            return
        }
        
        // Block request already going
        if request != nil {
            request?.cancel()
            return
        }
        
        let audioUrl = model.mp3URL!
        //audioUrl should be of type URL
        let audioFileName = String(audioUrl.lastPathComponent)!
        
        //path extension will consist of the type of file it is, m4a or mp4
        let pathExtension = audioFileName.pathExtension
        let name = model.podcastName!
        AudioViewManager.shared.setText(text: model.podcastName!)
        AudioViewManager.shared.startActivityIndicator()
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            // the name of the file here I kept is yourFileName with appended extension
            //@TODO: Set name
            documentsURL.appendPathComponent(name + "." + pathExtension)
            return (documentsURL, [.removePreviousFile])
        }

        self.request = Alamofire.download(audioUrl, to: destination)
            .downloadProgress { progress in
                log.info("Download Progress: \((progress.fractionCompleted * 100))")
            }
            .response { response in
                guard let destinationUrl = response.destinationURL else { return }
                model.update(mp3Saved: true)
                self.request = nil
                self.setSound(url: destinationUrl)
        }
    }
    
    func setSound(url: URL) {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            self.audioPlayer = player
            self.playAudio()
        } catch let error {
            log.error(error.localizedDescription)
        }
    }
    
    func isPlaying() -> Bool {
        guard audioPlayer != nil else { return false }
        if audioPlayer.isPlaying {
            return true
        }
        return false
    }
}

