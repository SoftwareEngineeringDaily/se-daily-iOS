//
//  PodcastCollectionViewCell.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/27/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import SnapKit
import KoalaTeaFlowLayout

class PodcastCollectionViewCell: UICollectionViewCell {
    
    var podcastModel: PodcastModel!
    
    let titleLabel = UILabel()
    let upVoteCountLabel = UILabel()
    let playButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(upVoteCountLabel)
        self.contentView.addSubview(playButton)
        
        self.contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 2.calculateWidth()
        contentView.layer.shadowColor = UIColor.lightGray.cgColor
        contentView.layer.shadowOpacity = 0.75
        contentView.layer.shadowOffset = CGSize(width: 0, height: 1.calculateHeight())
        contentView.layer.shadowRadius = 2.calculateWidth()
        
        titleLabel.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().inset(5.calculateHeight())
            make.left.right.equalToSuperview().inset(10.calculateWidth())
            make.height.equalToSuperview().dividedBy(2.5)
        }
        
        titleLabel.font = UIFont.systemFont(ofSize: 16.calculateWidth())
        titleLabel.adjustsFontSizeToFitWidth = false
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.minimumScaleFactor = 0.25
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = Stylesheet.Colors.offBlack
        
        upVoteCountLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.right.equalToSuperview().inset(2.calculateWidth())
            make.height.equalToSuperview().dividedBy(3)
        }

        upVoteCountLabel.font = UIFont.systemFont(ofSize: 22.calculateWidth())
        upVoteCountLabel.textAlignment = .center
        upVoteCountLabel.textColor = Stylesheet.Colors.offBlack
        upVoteCountLabel.text = "2"
        
        playButton.snp.makeConstraints{ (make) in
            make.top.equalTo(upVoteCountLabel.snp.bottom)
            make.bottom.equalToSuperview().inset(5.calculateHeight())
            make.left.right.equalToSuperview().inset(5.calculateWidth())
        }
        
        playButton.setTitle("Play", for: .normal)
        playButton.setTitleColor(Stylesheet.Colors.secondaryColor, for: .normal)
        playButton.addTarget(self, action: #selector(self.playButtonPressed), for: .touchUpInside)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    func setupCell(model: PodcastModel) {
        self.podcastModel = model
        guard let name = model.podcastName else { return }
        titleLabel.text = name
        guard let score = model.score else { return }
        upVoteCountLabel.text = score
    }
    
    func playButtonPressed() {
        AudioViewManager.shared.presentAudioView()
        AudioManager.shared.loadAudio(model: podcastModel)
    }
}
