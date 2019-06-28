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
	
	private let mainColor = UIColor(red:0.44, green:0.30, blue:1.00, alpha:1.0)
	
	private let imageView: UIImageView = UIImageView()
	private let skipForwardButton = UIButton()
	private let skipBackwardButton = UIButton()
	private let paceButton = UIButton()
	private let playButton = UIButton()
	private let infoButton = UIButton()
	private let collapseButton = UIButton()
	
	private let stackView = UIStackView()
	private let separator: UIView = UIView()
	private let label = UILabel()
	private let slider = UISlider()
	
	private var currentImage: UIImage = UIImage()
	
	var expanded: Bool = false {
		didSet {
			//setupLayout()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configure()
		//prepareForCollapsed()
	}
	
	@objc func infoTapped() {
		delegate?.didSelectInfo()
	}
	@objc func collapseTapped() {
		delegate?.didTapCollapse()
	}
}

extension OverlayViewController {
	
	private func configure() {
		
		view.backgroundColor = .white
		
		stackView.addArrangedSubview(paceButton)
		stackView.addArrangedSubview(skipBackwardButton)
		stackView.addArrangedSubview(playButton)
		stackView.addArrangedSubview(skipForwardButton)
		stackView.addArrangedSubview(infoButton)
		
		view.addSubview(stackView)
		view.addSubview(label)
		view.addSubview(imageView)
		view.addSubview(separator)
		view.addSubview(slider)
		view.addSubview(collapseButton)
		
		stackView.axis = .horizontal
		stackView.alignment = .fill
		stackView.distribution = .equalSpacing
		
		skipForwardButton.setImage(#imageLiteral(resourceName: "rewind_audio"), for: .normal)
		skipBackwardButton.setImage(#imageLiteral(resourceName: "forward_audio"), for: .normal)
		
		playButton.setImage(#imageLiteral(resourceName: "play_audio"), for: .normal)
		
		infoButton.setImage(#imageLiteral(resourceName: "play_audio"), for: .normal)
		infoButton.addTarget(self, action: #selector(OverlayViewController.infoTapped), for: .touchUpInside)
		
		paceButton.setImage(#imageLiteral(resourceName: "Square"), for: .normal)
		
		collapseButton.setImage(#imageLiteral(resourceName: "Arrow-Down"), for: .normal)
		collapseButton.addTarget(self, action: #selector(OverlayViewController.collapseTapped), for: .touchUpInside)
		
		label.text = "Service Mesh Interface with Lachlan Evenson"
		
		separator.backgroundColor = .lightGray
		
		slider.tintColor = mainColor
		slider.thumbTintColor = mainColor
	}
}

extension OverlayViewController {
	
	private func prepareForCollapsed() {
		
		slider.isHidden = true
		
		collapseButton.isHidden = true
		
		skipForwardButton.isHidden = true
		skipBackwardButton.isHidden = true
		
		infoButton.isHidden = true
		paceButton.isHidden = true
		
		label.font = UIFont(name: "Avenir", size: 13.0)
		label.textAlignment = .left
		label.numberOfLines = 2
		
		currentImage = #imageLiteral(resourceName: "download_panel")
		imageView.image = currentImage // for initial state
		
		playButton.setImage(#imageLiteral(resourceName: "play_audio"), for: .normal)
		
		imageView.layer.cornerRadius = 20.0
		imageView.layer.masksToBounds = true
		
		playButton.snp.remakeConstraints { (make) -> Void in
			make.size.equalTo(55).priority(999)
		}
		stackView.snp.remakeConstraints { (make) -> Void in
			make.right.equalToSuperview().inset(25.0)
			make.centerY.equalToSuperview()
		}
		imageView.snp.remakeConstraints { (make) -> Void in
			make.left.equalToSuperview().offset(10.0)
			make.centerY.equalToSuperview()
			make.size.equalTo(40)
		}
		label.snp.remakeConstraints { (make) -> Void in
			make.left.equalTo(imageView.snp.right).offset(15.0).priority(999)
			make.right.lessThanOrEqualTo(stackView.snp.left)
			make.centerY.equalToSuperview()
		}
		separator.snp.remakeConstraints { (make) -> Void in
			make.left.right.bottom.equalToSuperview()
			make.height.equalTo(0.3)
		}
	}
	
	private func prepareForExpanded() {
		
		slider.isHidden = false
		
		collapseButton.isHidden = false
		
		playButton.setImage(#imageLiteral(resourceName: "like"), for: .normal)
		
		label.font = UIFont(name: "Avenir", size: 20.0)
		label.textAlignment = .center
		
		skipForwardButton.isHidden = false
		skipBackwardButton.isHidden = false
		
		infoButton.isHidden = false
		paceButton.isHidden = false
		
		currentImage = #imageLiteral(resourceName: "download")
		
		imageView.layer.cornerRadius = 0.0
		imageView.contentMode = .scaleAspectFit
		
		stackView.snp.remakeConstraints { (make) -> Void in
			make.left.equalToSuperview().offset(20)
			make.right.equalToSuperview().inset(20)
			make.top.equalTo(slider.snp.bottom).offset(40.0)
			make.centerX.equalToSuperview()
		}
		collapseButton.snp.remakeConstraints { (make) -> Void in
			make.left.equalToSuperview().offset(5)
			if #available(iOS 11.0, *) {
				make.top.equalTo(view.safeAreaLayoutGuide).offset(10.0)
			} else {
				// Fallback on earlier versions
				make.top.equalToSuperview().offset(10.0)
			}
			make.size.equalTo(50)
		}
		playButton.snp.remakeConstraints { (make) -> Void in
			make.size.equalTo(80).priority(999)
		}
		slider.snp.remakeConstraints { (make) -> Void in
			make.left.equalToSuperview().offset(20)
			make.right.equalToSuperview().inset(20)
			make.top.equalTo(label.snp.bottom).offset(40.0)
			make.centerX.equalToSuperview()
		}
		imageView.snp.remakeConstraints { (make) -> Void in
			make.left.right.equalToSuperview()
			make.top.equalTo(collapseButton.snp.bottom).offset(20.0)
			make.height.equalTo(200)
		}
		label.snp.remakeConstraints { (make) -> Void in
			make.top.equalTo(imageView.snp.bottom).offset(40.0)
			make.rightMargin.leftMargin.equalToSuperview().inset(20.0)
		}
	}
	
	private func setupLayout() {
		
		self.expanded ? prepareForExpanded() : prepareForCollapsed()
		UIView.animate(withDuration: 0.2, animations: {
			self.view.layoutIfNeeded()
		})
		UIView.transition(with: imageView,
											duration: 0.2,
											options: .transitionCrossDissolve,
											animations: { self.imageView.image = self.currentImage },
											completion: nil)
	}
}


extension OverlayViewController: AudioOverlayDelegate {
	func animateOverlayIn() {
		
	}
	
	func animateOverlayOut() {
		
	}
	
	func playAudio(podcastViewModel: PodcastViewModel) {
		
		PlayProgressModelController.saveRecentlyListenedEpisodeId(id: podcastViewModel._id)
	}
	
	func pauseAudio() {
		
	}
	
	func stopAudio() {
		
	}
	
	func setCurrentShowingDetailView(podcastViewModel: PodcastViewModel?) {
		
	}
	
	
}
