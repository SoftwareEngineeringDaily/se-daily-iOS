//
//  PurchaseSubscriptionViewController.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 1/15/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit
import Stripe

class PurchaseSubscriptionViewController: UIViewController, STPAddCardViewControllerDelegate {

    let api = API.sharedInstance

    var planType: StripeParams.Plans?
    var monthlyContainerView = UIView()
    var yearlyContainerView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white

        let leftBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.dismissSelf))
        self.navigationItem.leftBarButtonItem = leftBarButton

        self.title = "Purchase Subscription"

        self.setupMonthlyContainer()
        self.setupYearlyContainer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupMonthlyContainer() {
        self.monthlyContainerView = UIView(leftInset: 20, topInset: 20, width: 335, height: 160)
        self.monthlyContainerView.layer.shadowColor = UIColor.lightGray.cgColor
        self.monthlyContainerView.layer.shadowRadius = 4
        self.monthlyContainerView.layer.shadowOpacity = 1
        self.monthlyContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.monthlyContainerView.backgroundColor = .white
        self.monthlyContainerView.layer.cornerRadius = monthlyContainerView.height / 16
        self.view.addSubview(monthlyContainerView)

        let typeLabel = UILabel(leftInset: 0, topInset: 30, width: 335, height: 40)
        typeLabel.text = "Monthly"
        let fontSize = UIView.getValueScaledByScreenWidthFor(baseValue: 34)
        typeLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        typeLabel.textColor = Stylesheet.Colors.base
        typeLabel.textAlignment = .center

        monthlyContainerView.addSubview(typeLabel)

        let selectButton = UIButton(leftInset: 0, topInset: 0, width: 160, height: 40)
        let leftInset = monthlyContainerView.center.x - 20 - (selectButton.width / 2)
        let topInset = typeLabel.frame.maxY + UIView.getValueScaledByScreenHeightFor(baseValue: 15)
        selectButton.x = leftInset
        selectButton.y = topInset
        selectButton.setTitle("$10/Month", for: .normal)
        selectButton.setTitleColor(.white, for: .normal)
        selectButton.backgroundColor = Stylesheet.Colors.secondaryColor
        selectButton.cornerRadius = selectButton.height / 2
        selectButton.addTarget(self, action: #selector(self.monthlyButtonPressed), for: .touchUpInside)
        monthlyContainerView.addSubview(selectButton)
    }

    @objc func monthlyButtonPressed() {
        self.planType = .monthly
        self.handleAddPaymentMethodButtonTapped()
    }

    func setupYearlyContainer() {
        self.yearlyContainerView = UIView(leftInset: 20, topInset: 0, width: 335, height: 160)
        self.yearlyContainerView.y = self.monthlyContainerView.frame.maxY + 20

        self.yearlyContainerView.layer.shadowColor = UIColor.lightGray.cgColor
        self.yearlyContainerView.layer.shadowRadius = 4
        self.yearlyContainerView.layer.shadowOpacity = 1
        self.yearlyContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.yearlyContainerView.backgroundColor = .white
        self.yearlyContainerView.layer.cornerRadius = yearlyContainerView.height / 16
        self.view.addSubview(yearlyContainerView)

        let typeLabel = UILabel(leftInset: 0, topInset: 30, width: 335, height: 40)
        typeLabel.text = "Yearly"
        let fontSize = UIView.getValueScaledByScreenWidthFor(baseValue: 34)
        typeLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        typeLabel.textColor = Stylesheet.Colors.base
        typeLabel.textAlignment = .center

        yearlyContainerView.addSubview(typeLabel)

        let selectButton = UIButton(leftInset: 0, topInset: 0, width: 160, height: 40)
        let leftInset = yearlyContainerView.center.x - 20 - (selectButton.width / 2)
        let topInset = typeLabel.frame.maxY + UIView.getValueScaledByScreenHeightFor(baseValue: 15)
        selectButton.x = leftInset
        selectButton.y = topInset
        selectButton.setTitle("$100/Year", for: .normal)
        selectButton.setTitleColor(.white, for: .normal)
        selectButton.backgroundColor = Stylesheet.Colors.secondaryColor
        selectButton.cornerRadius = selectButton.height / 2
        selectButton.addTarget(self, action: #selector(self.yearlyButtonPressed), for: .touchUpInside)
        yearlyContainerView.addSubview(selectButton)
    }

    @objc func yearlyButtonPressed() {
        self.planType = .yearly
        self.handleAddPaymentMethodButtonTapped()
    }

    @objc func dismissSelf() {
        self.dismiss(animated: true, completion: nil)
    }

    func handleAddPaymentMethodButtonTapped() {
        // Setup add card view controller
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self

        // Present add card view controller
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        present(navigationController, animated: true)
    }

    // MARK: STPAddCardViewControllerDelegate

    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        // Dismiss add card view controller
        dismiss(animated: true)
    }

    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        self.submitTokenToBackend(stripeToken: token, completion: { (error: Error?) in
            if let error = error {
                // Show error in add card view controller
                Helpers.alertWithMessage(title: L10n.genericError, message: error.localizedDescription)
                completion(error)
            } else {
                // Notify add card view controller that token creation was handled successfully
                self.dismiss(animated: true, completion: {
                    Helpers.alertWithMessageCustomAction(title: "🎉 You're subscribed! 🎉", message: "🙌 Thank you! 🙌\n Your support means the world to us!", actionTitle: "Yipee!", completionHandler: {
                        // Dismiss purchase view controller
                        self.dismiss(animated: true, completion: nil)
                    })
                })
                completion(nil)
            }
        })
    }

    func submitTokenToBackend(stripeToken: STPToken, completion: @escaping (Error?) -> Void) {
        guard let planType = self.planType else {
            assertionFailure("Plan type not set in VC")
            return
        }
        api.stripeCreateSubscription(token: stripeToken.tokenId, planType: planType) { (error) in
            completion(error)
        }
    }
}
