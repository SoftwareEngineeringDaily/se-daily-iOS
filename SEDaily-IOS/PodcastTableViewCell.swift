////
////  PodcastTableViewCell.swift
////  SEDaily-IOS
////
////  Created by Craig Holliday on 9/8/17.
////  Copyright © 2017 Koala Tea. All rights reserved.
////
//
//import Foundation
//import AVFoundation
//
//import UIKit
//import SnapKit
//import KTResponsiveUI
//import Skeleton
//import Kingfisher
//import Reusable
//
//class PodcastTableViewCell: UITableViewCell, Reusable {
//  var episodeImage: UIImageView!
//  var imageOverlay: UIView!
//  var titleLabel: UILabel!
//  var miscDetailsLabel: UILabel!
//  var descriptionLabel: UILabel!
//  
//  var actionView: ActionView!
//  
//  var commentShowCallback: (()-> Void) = {}
//  
//  let upvoteCountLabel: UILabel = UILabel()
//  
//  let upvoteStackView: UIStackView = UIStackView()
//  
//  let progressBar: UIProgressView = UIProgressView()
//  
//  // MARK: Skeleton
//
//  
//  
//  
//  var viewModel: PodcastViewModel = PodcastViewModel() {
//    willSet {
//      guard newValue != self.viewModel else { return }
//    }
//    didSet {
//      updateUI()
//    }
//  }
//  
//  var upvoteService: UpvoteService?
//  var bookmarkService: BookmarkService?
//  
//  var playProgress: PlayProgress?
//  
//  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//    super.init(style: style, reuseIdentifier: reuseIdentifier)
//    setupLayout()
//    setupButtonsTargets()
//  }
//  required init
//    (coder aDecoder: NSCoder) {
//    fatalError("init(coder:)")
//  }
//  //MARK: Button handlers
//  
//  private func setupButtonsTargets() {
//    actionView.upvoteButton.addTarget(self, action: #selector(PodcastTableViewCell.upvoteTapped), for: .touchUpInside)
//    actionView.bookmarkButton.addTarget(self, action: #selector(PodcastTableViewCell.bookmarkTapped), for: .touchUpInside)
//    actionView.commentButton.addTarget(self, action: #selector(PodcastTableViewCell.commentTapped), for: .touchUpInside)
//  }
//  
//  @objc func upvoteTapped() {
//    let impact = UIImpactFeedbackGenerator()
//    impact.impactOccurred()
//    
//    upvoteService?.UIDelegate = self
//    upvoteService?.upvote()
//  }
//  
//  @objc func bookmarkTapped() {
//    let selection = UISelectionFeedbackGenerator()
//    selection.selectionChanged()
//    
//    bookmarkService?.UIDelegate = self
//    bookmarkService?.setBookmark()
//  }
//  
//  @objc func commentTapped() {
//    let notification = UINotificationFeedbackGenerator()
//    notification.notificationOccurred(.success)
//    commentShowCallback()
//  }
//  
//
//}
//
//extension PodcastTableViewCell: UpvoteServiceUIDelegate {
//  func upvoteUIDidChange(isUpvoted: Bool, score: Int) {
//    actionView.upvoteButton.isSelected = isUpvoted
//    actionView.upvoteCountLabel.text = String(score)
//    updateLabelStyle()
//  }
//  
//  func upvoteUIImmediateUpdate() {
//    guard let tempScore = Int(actionView.upvoteCountLabel.text ?? "0") else { return }
//    actionView.upvoteCountLabel.text = actionView.upvoteButton.isSelected ? String(tempScore - 1) : String(tempScore + 1)
//    actionView.upvoteButton.isSelected = !actionView.upvoteButton.isSelected
//    updateLabelStyle()
//  }
//}
//
//extension PodcastTableViewCell {
//  func updateLabelStyle() {
//    actionView.upvoteCountLabel.textColor = actionView.upvoteButton.isSelected ? Stylesheet.Colors.base : Stylesheet.Colors.dark
//    actionView.upvoteCountLabel.font = actionView.upvoteButton.isSelected ? UIFont(name: "OpenSans-Semibold", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13)) : UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13))
//  }
//}
//
//extension PodcastTableViewCell: BookmarkServiceUIDelegate {
//  func bookmarkUIDidChange(isBookmarked: Bool) {
//    actionView.bookmarkButton.isSelected = isBookmarked
//  }
//  func bookmarkUIImmediateUpdate() {
//    actionView.bookmarkButton.isSelected = !actionView.bookmarkButton.isSelected
//  }
//}
//
//extension PodcastTableViewCell {
//  private func setupLayout() {
//    
//    backgroundColor = .white
//    
//    func setupEpisodeImage() {
//      episodeImage = UIImageView()
//      contentView.addSubview(episodeImage)
//      episodeImage.contentMode = .scaleAspectFill
//      episodeImage.clipsToBounds = true
//      episodeImage.cornerRadius = UIView.getValueScaledByScreenHeightFor(baseValue: 5)
//      episodeImage.kf.indicatorType = .activity
//      
//      imageOverlay = UIView()
//      contentView.addSubview(imageOverlay)
//      imageOverlay.clipsToBounds = true
//      imageOverlay.cornerRadius = UIView.getValueScaledByScreenHeightFor(baseValue: 5)
//      imageOverlay.backgroundColor = Stylesheet.Colors.lightTransparent
//    }
//    
//    func setupLabels() {
//      titleLabel = UILabel()
//      contentView.addSubview(titleLabel)
//      titleLabel.numberOfLines = 3
//      titleLabel.font = UIFont(name: "Roboto-Bold", size: UIView.getValueScaledByScreenWidthFor(baseValue: 17))
//      titleLabel.textColor = Stylesheet.Colors.dark
//      
//      miscDetailsLabel = UILabel()
//      contentView.addSubview(miscDetailsLabel)
//      miscDetailsLabel.font = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 11))
//      miscDetailsLabel.textColor = Stylesheet.Colors.dark
//      
//      descriptionLabel = UILabel()
//      descriptionLabel.numberOfLines = 2
//      descriptionLabel.font = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13))
//      descriptionLabel.textColor = Stylesheet.Colors.dark
//      contentView.addSubview(descriptionLabel)
//    }
//    
//    
//    func setupProgressBar() {
//      progressBar.progressTintColor = Stylesheet.Colors.base
//      progressBar.trackTintColor = Stylesheet.Colors.gray
//      progressBar.transform = progressBar.transform.scaledBy(x: 1, y: 1)
//      progressBar.isHidden = true
//      contentView.addSubview(progressBar)
//    }
//    
//    func setupActionView() {
//      actionView = ActionView()
//      actionView.setupComponents(superview: contentView)
//    }
//    
//    
//    func setupConstraints() {
//      episodeImage.snp.makeConstraints { (make) -> Void in
//        make.left.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue:15))
//        make.top.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue:10))
//        make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 80))
//        make.height.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 80))
//      }
//      
//      
//      imageOverlay.snp.makeConstraints { (make) -> Void in
//        make.left.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue:15))
//        make.top.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue:10))
//        make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue:80))
//        make.height.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue:80))
//      }
//      
//      titleLabel.snp.makeConstraints { (make) -> Void in
//        make.top.equalTo(episodeImage)
//        make.rightMargin.equalTo(contentView).inset(UIView.getValueScaledByScreenWidthFor(baseValue:15.0))
//        make.left.equalTo(episodeImage.snp.right).offset(UIView.getValueScaledByScreenWidthFor(baseValue:10.0))
//      }
//      
//      miscDetailsLabel.snp.makeConstraints { (make) -> Void in
//        make.top.equalTo(titleLabel.snp.bottom).offset(UIView.getValueScaledByScreenWidthFor(baseValue:5.0))
//        make.left.equalTo(titleLabel)
//      }
//      
//      descriptionLabel.snp.makeConstraints { (make) -> Void in
//        make.top.equalTo(episodeImage.snp.bottom).offset(UIView.getValueScaledByScreenWidthFor(baseValue:10.0))
//        make.rightMargin.equalTo(contentView).inset(UIView.getValueScaledByScreenWidthFor(baseValue:15.0))
//        make.left.equalTo(episodeImage)
//      }
//      actionView.setupContraints()
//      
//      actionView.actionStackView.snp.makeConstraints { (make) -> Void in
//        make.top.equalTo(descriptionLabel.snp.bottom).offset(UIView.getValueScaledByScreenWidthFor(baseValue:10.0))
//        make.bottom.equalTo(contentView)
//        make.left.equalTo(episodeImage)
//      }
//      
//      progressBar.snp.makeConstraints { (make) -> Void in
//        make.width.equalTo(contentView)
//        make.rightMargin.equalTo(contentView)
//        make.leftMargin.equalTo(contentView)
//        make.bottom.equalTo(contentView)
//      }
//    }
//    
//    setupEpisodeImage()
//    setupLabels()
//    setupProgressBar()
//    setupActionView()
//    setupConstraints()
//  }
//}
//
//extension PodcastTableViewCell {
//  private func updateUI() {
//    
//    self.titleLabel.text = viewModel.podcastTitle
//    
//    func loadepisodeImage(imageURL: URL?) {
//      episodeImage.kf.cancelDownloadTask()
//      guard let imageURL = imageURL else {
//        episodeImage.image = #imageLiteral(resourceName: "SEDaily_Logo")
//        return
//      }
//      episodeImage.kf.setImage(with: imageURL, options: [.transition(.fade(0.2))])
//    }
//    
//    func setupMiscDetailsLabel(timeLength: Int?, date: Date?, isDownloaded: Bool) {
//      let dateString = date?.dateString() ?? ""
//      let timeLeftString = isProgressSet() ? createTimeLeftString() : ""
//      miscDetailsLabel.text = dateString + timeLeftString
//    }
//    
//    func createTimeLeftString()->String {
//      return " · " + Helpers.createTimeString(time: playProgress?.timeLeft ?? 0.0, units: [.minute]) + " " + L10n.timeLeft
//    }
//    
//    func setupDescriptionLabel() {
//      var str: String!
//      // Due to asynchronuous nature of decoding html content, this is a better way to do it
//      DispatchQueue.global(qos: .background).async { [weak self] in
//        str = self?.viewModel.podcastDescription
//        DispatchQueue.main.async {
//          
//          self?.descriptionLabel.text = str
//        }
//      }
//      
//    }
//    
//    func updateUpvote() {
//      actionView.upvoteCountLabel.text = String(viewModel.score)
//      actionView.upvoteButton.isSelected = viewModel.isUpvoted
//      actionView.upvoteCountLabel.textColor = actionView.upvoteButton.isSelected ? Stylesheet.Colors.base : Stylesheet.Colors.dark
//      actionView.upvoteCountLabel.font = actionView.upvoteButton.isSelected ? UIFont(name: "OpenSans-Semibold", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13)) : UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13))
//    }
//    
//    func updateBookmark() {
//      actionView.bookmarkButton.isSelected = viewModel.isBookmarked
//    }
//    
//    func updateProgressBar() {
//      guard let playProgress = playProgress else { return }
//      if isProgressSet() {
//        progressBar.progress = playProgress.progressFraction
//        progressBar.isHidden = false
//      } else {
//        progressBar.isHidden = true
//      }
//    }
//    
//    func isProgressSet()->Bool {
//      guard let playProgress = playProgress else { return false }
//      return playProgress.progressFraction > Float(0.005)
//    }
//    
//    loadepisodeImage(imageURL: viewModel.featuredImageURL)
//    viewModel.getLastUpdatedAsDateWith { [weak self] (date) in
//      guard let strongSelf = self else { return }
//      setupMiscDetailsLabel(timeLength: nil, date: date, isDownloaded: strongSelf.viewModel.isDownloaded)
//    }
//    updateProgressBar()
//    setupDescriptionLabel()
//    updateUpvote()
//    updateBookmark()
//  }
//}
//
//
