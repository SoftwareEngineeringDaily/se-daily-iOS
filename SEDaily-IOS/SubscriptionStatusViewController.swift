//
//  SubscriptionStatusViewController.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 1/15/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit

class SubscriptionStatusViewController: UIViewController {

    let api = API.sharedInstance
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
        typeLabel.text = "Your "
        let fontSize = UIView.getValueScaledByScreenWidthFor(baseValue: 22)
        typeLabel.font = UIFont.systemFont(ofSize: fontSize)
//        typeLabel.textColor = Stylesheet.Colors.base
        typeLabel.textAlignment = .center

        yearlyContainerView.addSubview(typeLabel)

        let selectButton = UIButton(leftInset: 0, topInset: 0, width: 220, height: 40)
        let leftInset = yearlyContainerView.center.x - 20 - (selectButton.width / 2)
        let topInset = typeLabel.frame.maxY + UIView.getValueScaledByScreenHeightFor(baseValue: 15)
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

            let attributedText = NSMutableAttributedString(string: "Your plan: ", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: fontSize)])
            let attributedText2 = NSMutableAttributedString(string: subscriptionModel.getPlanFrequency(), attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize)])
            attributedText.append(attributedText2)
            typeLabel.attributedText = attributedText
        }

//        attributedText.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.blue, NSAttributedStringKey.font: UIFont(name: "AvenirNext-Bold", size: 15)!], range: getRangeOfSubString(subString: "BLUE", fromString: normalString)) // Blue color attribute
//
//        attributedText.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.red, NSAttributedStringKey.font: UIFont(name: "Baskerville-BoldItalic", size: 27)!], range: getRangeOfSubString(subString: "RED", fromString: normalString)) // RED color attribute
//
//        attributedText.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.green, NSAttributedStringKey.font: UIFont(name: "Chalkduster", size: 19)!], range: getRangeOfSubString(subString: "GREEN", fromString: normalString)) // GREEN color attribute
//
//        attributedText.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.purple, NSAttributedStringKey.font: UIFont(name: "DINCondensed-Bold", size: 13)!], range: getRangeOfSubString(subString: "PURPLE", fromString: normalString)) // PURPLE color attribute
//
//        attributedText.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.yellow, NSAttributedStringKey.font: UIFont(name: "Futura-CondensedExtraBold", size: 24)!], range: getRangeOfSubString(subString: "YELLOW", fromString: normalString)) // YELLOW color attribute
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
