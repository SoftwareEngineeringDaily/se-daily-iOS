//
//  StateBookmarkView.swift
//  SEDaily-IOS
//
//  Created by Justin Lam on 12/16/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation
import UIKit

protocol StateViewDelegate: class {
    func refreshPressed()
}

/// Generic view for states used in view controllers
class StateView: UIView {
    private var stackView: UIStackView!
    private var refreshButton: UIButton!
    weak var delegate: StateViewDelegate?

    init(
        frame: CGRect,
        text: String,
        showLoadingIndicator: Bool,
        showRefreshButton: Bool,
        delegate: StateViewDelegate?) {
        super.init(frame: frame)

        self.delegate = delegate

        self.stackView = UIStackView()
        self.stackView.axis = .vertical
        self.addSubview(self.stackView)

        let label = UILabel(text: text)

        let horizontalStackView = UIStackView()
        horizontalStackView.spacing = 10
        if showLoadingIndicator {
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.startAnimating()
            activityIndicator.color = UIColor.gray
            horizontalStackView.addArrangedSubview(activityIndicator)
        }
        horizontalStackView.addArrangedSubview(label)

        self.stackView.addArrangedSubview(horizontalStackView)

        if showRefreshButton {
            self.refreshButton = UIButton()
            self.refreshButton.setTitle(L10n.tapToRefresh, for: .normal)
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
