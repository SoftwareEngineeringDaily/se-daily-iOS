//
//  StateBookmarkView.swift
//  SEDaily-IOS
//
//  Created by Justin Lam on 12/16/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation
import UIKit

/// Generic view for states used in BookmarkCollectionViewController
class StateBookmarkView: UIView {
    private var stackView: UIStackView!
    private var label: UILabel!
    private var refreshButton: UIButton!
    weak var delegate: BookmarkCollectionViewControllerDelegate?

    init(
        frame: CGRect,
        text: String,
        showRefreshButton: Bool,
        delegate: BookmarkCollectionViewControllerDelegate?) {
        super.init(frame: frame)

        self.delegate = delegate

        self.stackView = UIStackView()
        self.stackView.axis = .vertical
        self.addSubview(self.stackView)

        self.label = UILabel(text: text)
        self.stackView.addArrangedSubview(self.label)

        if showRefreshButton {
            self.refreshButton = UIButton()
            self.refreshButton.setTitle("Tap to refresh", for: .normal)
            self.refreshButton.setTitleColor(UIColor.init(hex: 0x007AFF), for: .normal)
            self.refreshButton.addTarget(self, action: #selector(self.refreshPressed), for: .touchUpInside)
            self.stackView.addArrangedSubview(self.refreshButton)
        }

        self.stackView.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
        }
    }

    @objc func refreshPressed() {
        self.delegate?.refreshPressed()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
