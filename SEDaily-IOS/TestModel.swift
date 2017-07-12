//
//  TestModel.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 7/3/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation
import UIKit
//
//struct Video {
//    enum State {
//        case willDownload(from: URL)
//        case downloading(task: Task)
//        case playing(PlaybackState)
//        case paused(PlaybackState)
//    }
//    
//    var state: State
//}
//
//extension Video {
//    struct PlaybackState {
//        let file: File
//        var progress: Double
//    }
//}
//
//extension Video {
//    var downloadTask: Task? {
//        guard case let .downloading(task) = state else {
//            return nil
//        }
//        
//        return task
//    }
//}
//
//class VideoPlayerViewController: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//    var video: Video {
//        // Every time the video changes, we re-render
//        didSet { render() }
//    }
//    
//    fileprivate lazy var actionButton = UIButton()
//    
//    private func render() {
//        renderActionButton()
//    }
//    
//    private func renderActionButton() {
//        let actionButtonImage = resolveActionButtonImage()
//        actionButton.setImage(actionButtonImage, for: .normal)
//    }
//    
//    private func resolveActionButtonImage() -> UIImage {
//        // The image for the action button is declaratively resolved
//        // directly from the video state
//        switch video.state {
//            // We can easily discard associated values that we don't need
//        // by simply omitting them
//        case .willDownload:
//            return .wait
//        case .downloading:
//            return .cancel
//        case .playing:
//            return .pause
//        case .paused:
//            return .play
//        }
//    }
//}
//
//private extension VideoPlayerViewController {
//    func handleStateChange() {
//        switch video.state {
//        case .willDownload(let url):
//            // Start a download task and enter the 'downloading' state
//            let task = Task.download(url: url)
//            task.start()
//            video.state = .downloading(task: task)
//        case .downloading(let task):
//            // If the download task finished, start playback
//            switch task.state {
//            case .inProgress:
//                break
//            case .finished(let file):
//                let playbackState = Video.PlaybackState(file: file, progress: 0)
//                video.state = .playing(playbackState)
//            }
//        case .playing:
//            player.play()
//        case .paused:
//            player.pause()
//        }
//    }
//}
