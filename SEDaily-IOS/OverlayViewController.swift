//
//  OverlayViewController.swift
//  ExpandableOverlay
//
//  Created by Dawid Cedrych on 6/18/19.
//  Copyright © 2019 Altalogy. All rights reserved.
//

import UIKit
import SnapKit

protocol OverlayViewDelegate: class {
  func didSelectInfo()
  func didTapCollapse()
}

class OverlayViewController: UIViewController {
  
  weak var delegate: OverlayViewDelegate?
  
  var viewModel: PodcastViewModel = PodcastViewModel() {
    didSet {
      audioPlayerView?.viewModel = viewModel
      audioPlayerView?.expanded = false
      audioPlayerView?.performLayout()
    }
  }
  
  
  var expanded: Bool = false {
    didSet {
      audioPlayerView?.expanded = expanded
    }
  }
  
  var audioPlayerView: AudioPlayerView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    audioPlayerView = AudioPlayerView(frame: CGRect.zero)
    view.addSubview(audioPlayerView!)
    audioPlayerView?.snp.remakeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  @objc func infoTapped() {
    delegate?.didSelectInfo()
  }
  @objc func collapseTapped() {
    delegate?.didTapCollapse()
  }
}

extension OverlayViewController: AudioOverlayDelegate {
  func animateOverlayIn() {
    
  }
  
  func animateOverlayOut() {
    
  }
  
  func pauseAudio() {
    
  }
  
  
  func playAudio(podcastViewModel: PodcastViewModel) {
    
    PlayProgressModelController.saveRecentlyListenedEpisodeId(id: podcastViewModel._id)
  }
  
  
  func stopAudio() {
    
  }
  
  func setCurrentShowingDetailView(podcastViewModel: PodcastViewModel?) {
    
  }
  
  
}
