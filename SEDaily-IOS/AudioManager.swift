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

class Task {
    enum State {
        case finished(File)
        case inProgress
    }
    
    var state: State {
        didSet {
            AudioManager.shared.audio.state = .downloading(task: self)
        }
    }
    
    var request: Alamofire.Request? = nil
    var progress: Double? = nil
    
    init(state: State) {
        self.state = state
    }
    
    func download(audioUrl: URL, model: PodcastModel) {
        
        guard model.mp3Saved != true else {
            log.info(model.getSavedMP3URL())
            let file = File(fileURL: model.getSavedMP3URL())
            self.state = .finished(file)
            return
        }
        
        //audioUrl should be of type URL
        let audioFileName = String(audioUrl.lastPathComponent)!
        
        //path extension will consist of the type of file it is, m4a or mp4
        let pathExtension = audioFileName.pathExtension
        let name = model.podcastName!
        
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
                self.progress = progress.fractionCompleted * 100
            }
            .response { response in
                guard let destinationUrl = response.destinationURL else { return }
                model.update(mp3Saved: true)
                
                self.request = nil
                
                let file = File(fileURL: destinationUrl)
                self.state = .finished(file)
                log.info(destinationUrl)
            }
    }
}

struct File {
    var fileURL: URL
}

struct Audio {
    enum State {
        case stopped
        case willDownload(from: PodcastModel)
        case downloading(task: Task)
        case playing(PlaybackState)
//        case paused(PlaybackState)
        case paused
    }
    
    var state: State
    
    var audioPlayer: AVAudioPlayer!
}

extension Audio {
    struct PlaybackState {
        let file: File
        var progress: Double
    }
}

extension Audio {
    var downloadTask: Task? {
        guard case let .downloading(task) = state else {
            return nil
        }
        
        return task
    }
}

public class AudioManager {
    static let shared: AudioManager = AudioManager()
    private init() {}
    
    var podcastModel: PodcastModel!

    var audio = Audio(state: .stopped, audioPlayer: nil) {
        // Every time the video changes, we re-render
        didSet {
            layoutAudioViewManager()
            handleStateChange()
        }
    }
    
    var task: Task!
    var playbackState: Audio.PlaybackState!
    
    func layoutAudioViewManager() {
        AudioViewManager.shared.handleAudioManagerStateChange()
    }
    
    func handleStateChange() {
        //@TODO: need a state for audio did finish
        //@TODO: Stop any ongoing tasks
        switch audio.state {
        case .stopped:
            guard audio.audioPlayer != nil else { return }
            log.info("stopped")
//            audio.audioPlayer.stop()
            // @TODO: maybe don't set to nil but setting it right now for testing purposes
            //@TODO: Also changing the state again cause infinit loop
            //@TODO: Save progress
            audio.audioPlayer = nil
        case .willDownload(let model):
            //@TODO: Should we stop audio when downloading?
            // Start a download task and enter the 'downloading' state
            self.podcastModel = model
            
            if task != nil {
                task.request?.cancel()
            }
            
            task = Task(state: .inProgress)
            
            guard let audioURL = model.getMP3asURL() else {
                //@TODO: Some error here
                log.error("no original audio url?")
                break
            }
            
            task.download(audioUrl: audioURL, model: model)
            audio.state = .downloading(task: task)
        case .downloading(let task):
            // If the download task finished, start playback
            switch task.state {
            case .inProgress:
                break
            case .finished(let file):
                let playbackState = Audio.PlaybackState(file: file, progress: 0)
                audio.state = .playing(playbackState)
            }
        case .playing(let playbackState):
            // Audio already playing
            // Hmm not sure if I should still have a guard here or fix state (see below)
            //@TODO: This isn't the right guard
            guard audio.audioPlayer == nil else { break }
//            if self.playbackState != nil {
//                guard playbackState.file.fileURL != self.playbackState.file.fileURL else { return }
//            }
            
            self.playbackState = playbackState

            do {
                log.info("here")
                let audioPlayer = try AVAudioPlayer(contentsOf: playbackState.file.fileURL, fileTypeHint: "mp3")
                
                // Here we're changing the audio state again so we get an infinit loop
                self.audio.audioPlayer = audioPlayer
                
//                podcastModel.update(currentTime: 20.0)
//                if let currentTime = podcastModel.getCurrentTime() {
//                    self.audio.audioPlayer.currentTime = currentTime
//                }
                self.audio.audioPlayer.play()
            } catch let error {
                log.error(error.localizedDescription)
                break
            }
        case .paused:
            guard audio.audioPlayer != nil else { return }
            //@TODO: Save progress
            audio.audioPlayer.pause()
        }
    }
    
    func setupSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        } catch let error {
            log.error(error.localizedDescription)
        }
    }
    
    
//    func playAudio() {
//        if self.isPlaying() {
//            audioPlayer.stop()
//        }
//        
//        if request != nil {
//            request?.resume()
//            return
//        }
//        AudioViewManager.shared.stopActivityIndicator()
//        
//        guard audioPlayer != nil else { return }
//        audioPlayer.play()
//        NotificationCenter.default.post(name: .playingAudio, object: nil)
//    }
//    
//    func pauseAudio() {
//        if request != nil {
//            request?.suspend()
//            return
//        }
//        
//        guard audioPlayer != nil else { return }
//        log.info(audioPlayer.currentTime)
//        audioPlayer.pause()
//        NotificationCenter.default.post(name: .playingAudio, object: nil)
//    }
//    
//    func stopAudio() {
//        if request != nil {
//            request?.cancel()
//            //@TODO: cancel audio if playing?
//            return
//        }
//        
//        AudioViewManager.shared.stopActivityIndicator()
//        
//        guard audioPlayer != nil else { return }
//        audioPlayer.stop()
//        audioPlayer = nil
//    }
//    
//    func loadAudio(model: PodcastModel) {
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
//        } catch let error {
//            log.error(error.localizedDescription)
//        }
//
//        if model.mp3Saved == true {
//            self.setSound(url: model.getMP3URL())
//            AudioViewManager.shared.setText(text: model.podcastName!)
//            return
//        }
//
//        // Block request already going
//        if request != nil {
//            request?.cancel()
//            return
//        }
//        
//        let audioUrl = model.mp3URL!
//        
//    }
//    
//    func setSound(url: URL) {
//        do {
//            let player = try AVAudioPlayer(contentsOf: url)
//            self.audioPlayer = player
//            self.playAudio()
//        } catch let error {
//            log.error(error.localizedDescription)
//        }
//    }
//    
    func isPlaying() -> Bool {
        guard audio.audioPlayer != nil else { return false }
        if audio.audioPlayer.isPlaying {
            return true
        }
        return false
    }
}

