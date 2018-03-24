//
//  SubscriptionStatusViewController.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 1/15/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit

class SubscriptionStatusViewController: UIViewController {

    let api = API()
    var yearlyContainerView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        let leftBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.dismissSelf))
        self.navigationItem.leftBarButtonItem = leftBarButton

        self.title = "Your Subscription"

        self.yearlyContainerView = UIView(leftInset: 20, topInset: 0, width: 335, height: 160)
        self.yearlyContainerView.y = 20

        self.yearlyContainerView.backgroundColor = .white
        self.yearlyContainerView.layer.cornerRadius = yearlyContainerView.height / 16
        self.view.addSubview(yearlyContainerView)

        let typeLabel = UILabel(leftInset: 0, topInset: 30, width: 335, height: 40)
        typeLabel.textAlignment = .center
        yearlyContainerView.addSubview(typeLabel)

        let startDateLeftInset = typeLabel.frame.minX
        let startDateTopInset = typeLabel.frame.maxY
        let startDateLabel = UILabel(leftInset: startDateLeftInset, topInset: startDateTopInset, width: 335, height: 40)
        startDateLabel.textAlignment = .center
        yearlyContainerView.addSubview(startDateLabel)

        let selectButton = UIButton(leftInset: 0, topInset: 0, width: 220, height: 40)
        let leftInset = yearlyContainerView.center.x - 20 - (selectButton.width / 2)
        let topInset = startDateLabel.frame.maxY + UIView.getValueScaledByScreenHeightFor(baseValue: 15)
        selectButton.x = leftInset
        selectButton.y = topInset
        selectButton.setTitle("Cancel Subscription", for: .normal)
        selectButton.setTitleColor(.white, for: .normal)
        selectButton.backgroundColor = Stylesheet.Colors.secondaryColor
        selectButton.cornerRadius = selectButton.height / 2
        selectButton.addTarget(self, action: #selector(self.cancelButtonPressed), for: .touchUpInside)
        yearlyContainerView.addSubview(selectButton)

        api.loadUserInfo { (subscriptionModel) in
            guard let subscriptionModel = subscriptionModel else {
                assertionFailure("Subscription model is nil")
                return
            }

            let fontSize = UIView.getValueScaledByScreenWidthFor(baseValue: 22)

            let attributedText = NSMutableAttributedString(string: "Your plan: ", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: fontSize)])
            let attributedText2 = NSMutableAttributedString(string: subscriptionModel.getPlanFrequency(), attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize)])
            attributedText.append(attributedText2)
            typeLabel.attributedText = attributedText

            let startDateAttrText1 = NSMutableAttributedString(string: "Start Date: ", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: fontSize)])
            let startDateAttrText2 = NSMutableAttributedString(string: subscriptionModel.getCreatedAtDate()!.dateString(), attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize)])
            startDateAttrText1.append(startDateAttrText2)
            startDateLabel.attributedText = startDateAttrText1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func dismissSelf() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func cancelButtonPressed() {
        let alert = UIAlertController(title: "🛑🛑 Are you sure? 🛑🛑", message: "You are about to cancel your subscription", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes I'm sure.", style: .destructive, handler: { (_) in
            self.cancelSubscription()
        }))
        alert.addAction(UIAlertAction(title: "No stop now!", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func cancelSubscription() {
        ProgressIndicator.showBlockingProgress()
        api.stripeCancelSubscription { (error) in
            ProgressIndicator.hideBlockingProgress()
            guard let error = error else {
                // Show Success
                Helpers.alertWithMessageCustomAction(title: L10n.genericSuccess, message: "Your subscription has been canceled.", actionTitle: "Thanks!", completionHandler: {
                    self.dismiss(animated: true, completion: nil)
                })

                return
            }
            // Show Error
            Helpers.alertWithMessage(title: L10n.genericError, message: error.localizedDescription)
        }
    }
}
