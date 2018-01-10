//
//  LoginViewController.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/27/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import SwifterSwift
import SideMenu
import MBProgressHUD

class LoginViewController: UIViewController {

    //    let containerView = UIView()
    let scrollView = UIScrollView()
    let contentView = UIView()
    let topView = UIView()
    let bottomView = UIView()

    let imageView = UIImageView()
    let stackView = UIStackView()

    let emailTextField = TextField()
    let usernameTextField = TextField()
    let passwordTextField = TextField()
    let passwordConfirmTextField = TextField()
    let firstNameTextField = TextField()
    let lastNameTextField = TextField()

    let loginButton = UIButton()
    let cancelButton = UIButton()
    let signUpButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        performLayout()
        self.view.backgroundColor = Stylesheet.Colors.base
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func addBottomBorderToView(view: UIView, height: CGFloat, width: CGFloat) {
        let border = CALayer()
        let borderWidth = CGFloat(UIView.getValueScaledByScreenHeightFor(baseValue: 2))
        border.borderColor = Stylesheet.Colors.secondaryColor.cgColor
        border.frame = CGRect(x: 0, y: height - borderWidth, width: width, height: height)

        border.borderWidth = borderWidth
        view.layer.addSublayer(border)
        view.layer.masksToBounds = true
    }

    private func performLayout() {
        self.view.addSubview(scrollView)

        scrollView.snp.makeConstraints { (make) -> Void in
            make.edges.equalToSuperview()
        }

        self.scrollView.addSubview(contentView)
        self.contentView.addSubview(stackView)

        contentView.snp.makeConstraints { (make) -> Void in
            make.top.left.right.equalToSuperview().priority(100)
            make.width.equalToSuperview()
            make.bottom.equalToSuperview().priority(99)
            make.bottom.equalTo(stackView.snp.bottom).offset(20).priority(100)
        }

        setupStackView()
        setupImageview()
        setupTextFields()
        setupButtons()
    }
    private func setupTopBottomViews() {
        self.view.addSubview(topView)
        self.view.addSubview(bottomView)

        topView.isUserInteractionEnabled = false
        bottomView.isUserInteractionEnabled = false

        topView.snp.makeConstraints { (make) -> Void in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(view).dividedBy(2)
        }

        bottomView.snp.makeConstraints { (make) -> Void in
            make.bottom.left.right.equalTo(view)
            make.height.equalTo(view).dividedBy(2)
        }
    }

    private func setupStackView() {
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 10

        self.stackView.addArrangedSubview(emailTextField)
        self.stackView.addArrangedSubview(usernameTextField)
        self.stackView.addArrangedSubview(passwordTextField)
        self.stackView.addArrangedSubview(passwordConfirmTextField)
        self.stackView.addArrangedSubview(firstNameTextField)
        self.stackView.addArrangedSubview(lastNameTextField)
        self.stackView.addArrangedSubview(loginButton)
        self.stackView.addArrangedSubview(signUpButton)
        self.stackView.addArrangedSubview(cancelButton)

        stackView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.view.center)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(cancelButton)
        }
    }

    private func setupImageview() {
        self.scrollView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "SEDaily_Logo")

        imageView.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(50)

            let height = UIView.getValueScaledByScreenHeightFor(baseValue: 200)
            make.height.equalTo(height)
            make.width.equalTo(height)
        }
    }

    private func setupTextFields() {
        let width = UIView.getValueScaledByScreenWidthFor(baseValue: 316)
        let height = UIView.getValueScaledByScreenHeightFor(baseValue: 36)
        emailTextField.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(width)
            make.height.equalTo(height)
        }
        
        usernameTextField.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(width)
            make.height.equalTo(height)
        }

        passwordTextField.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(width)
            make.height.equalTo(height)
        }

        passwordConfirmTextField.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(width)
            make.height.equalTo(height)
        }

        firstNameTextField.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(width)
            make.height.equalTo(height)
        }

        lastNameTextField.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(width)
            make.height.equalTo(height)
        }

        addBottomBorderToView(view: emailTextField, height: height, width: width)
        addBottomBorderToView(view: usernameTextField, height: height, width: width)
        addBottomBorderToView(view: passwordTextField, height: height, width: width)
        addBottomBorderToView(view: passwordConfirmTextField, height: height, width: width)
        addBottomBorderToView(view: firstNameTextField, height: height, width: width)
        addBottomBorderToView(view: lastNameTextField, height: height, width: width)

        emailTextField.placeholder = L10n.usernameOrEmailPlaceholder
        emailTextField.setPlaceHolderTextColor(Stylesheet.Colors.secondaryColor)
        emailTextField.textColor = Stylesheet.Colors.white
        emailTextField.autocorrectionType = .no
        emailTextField.autocapitalizationType = .none
        
        usernameTextField.isHidden = true
        usernameTextField.placeholder = L10n.usernamePlaceholder
        usernameTextField.setPlaceHolderTextColor(Stylesheet.Colors.secondaryColor)
        usernameTextField.textColor = Stylesheet.Colors.white
        usernameTextField.autocorrectionType = .no
        usernameTextField.autocapitalizationType = .none

        passwordTextField.placeholder = L10n.passwordPlaceholder
        passwordTextField.setPlaceHolderTextColor(Stylesheet.Colors.secondaryColor)
        passwordTextField.textColor = Stylesheet.Colors.white
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        passwordTextField.isSecureTextEntry = true

        passwordConfirmTextField.isHidden = true
        passwordConfirmTextField.placeholder = L10n.confirmPasswordPlaceholder
        passwordConfirmTextField.setPlaceHolderTextColor(Stylesheet.Colors.secondaryColor)
        passwordConfirmTextField.textColor = Stylesheet.Colors.white
        passwordConfirmTextField.autocorrectionType = .no
        passwordConfirmTextField.autocapitalizationType = .none
        passwordConfirmTextField.isSecureTextEntry = true

        firstNameTextField.isHidden = true
        firstNameTextField.placeholder = L10n.firstNamePlaceholder
        firstNameTextField.setPlaceHolderTextColor(Stylesheet.Colors.secondaryColor)
        firstNameTextField.textColor = Stylesheet.Colors.white
        firstNameTextField.autocorrectionType = .no
        firstNameTextField.autocapitalizationType = .none

        lastNameTextField.isHidden = true
        lastNameTextField.placeholder = L10n.lastNamePlaceholder
        lastNameTextField.setPlaceHolderTextColor(Stylesheet.Colors.secondaryColor)
        lastNameTextField.textColor = Stylesheet.Colors.white
        lastNameTextField.autocorrectionType = .no
        lastNameTextField.autocapitalizationType = .none
    }

    private func setupButtons() {
        let width = UIView.getValueScaledByScreenWidthFor(baseValue: 94)
        let height = UIView.getValueScaledByScreenHeightFor(baseValue: 42)
        loginButton.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(width)
            make.height.equalTo(height)
        }

        cancelButton.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(width)
            make.height.equalTo(height)
        }

        signUpButton.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(width)
            make.height.equalTo(height)
        }

        loginButton.setTitle(L10n.loginButtonTitle, for: .normal)
        let cornerRadius = UIView.getValueScaledByScreenWidthFor(baseValue: 4)
        loginButton.setTitleColor(Stylesheet.Colors.white, for: .normal)
        loginButton.setBackgroundColor(color: Stylesheet.Colors.secondaryColor, forState: .normal)
        loginButton.addTarget(self, action: #selector(self.loginButtonPressed), for: .touchUpInside)
        loginButton.cornerRadius = cornerRadius

        cancelButton.setTitle(L10n.cancelButtonTitle, for: .normal)
        cancelButton.setTitleColor(Stylesheet.Colors.white, for: .normal)
        cancelButton.setBackgroundColor(color: Stylesheet.Colors.secondaryColor, forState: .normal)
        cancelButton.addTarget(self, action: #selector(self.cancelButtonPressed), for: .touchUpInside)
        cancelButton.cornerRadius = cornerRadius
        cancelButton.isHidden = true

        signUpButton.setTitle(L10n.signUpButtonTitle, for: .normal)
        signUpButton.setTitleColor(Stylesheet.Colors.white, for: .normal)
        signUpButton.setBackgroundColor(color: Stylesheet.Colors.secondaryColor, forState: .normal)
        signUpButton.addTarget(self, action: #selector(self.signUpButtonPressed), for: .touchUpInside)
        signUpButton.cornerRadius = cornerRadius
    }

    @objc func loginButtonPressed() {
        guard !emailTextField.isEmpty else {
            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.emailEmpty)
            return
        }

        guard let usernameOrEmail = emailTextField.text else { return }
        // @TODO: Maybe add another check here
//        guard Helpers.isValidEmailAddress(emailAddressString: email) else {
//            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.emailWrongFormat)
//            return
//        }

        guard !passwordTextField.isEmpty else {
            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.passwordEmpty)
            return
        }

        guard let password = passwordTextField.text else { return }
        guard password.length >= 6 else {
            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.passwordNotLongEnough)
            return
        }

        ProgressIndicator.showBlockingProgress()
        API.sharedInstance.login(usernameOrEmail: usernameOrEmail, password: password) { (success) in
            ProgressIndicator.hideBlockingProgress()
            if success == false {
                return
            }
            self.navigationController?.popViewController()
        }
    }

    @objc func cancelButtonPressed() {
        UIView.animate(withDuration: 0.15, animations: {
            self.loginButton.isHidden = false
            self.cancelButton.isHidden = true
            
            // Set email field back to "username or email"
            self.emailTextField.placeholder = L10n.usernameOrEmailPlaceholder
            self.emailTextField.setPlaceHolderTextColor(Stylesheet.Colors.secondaryColor)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15, animations: {
                self.usernameTextField.alpha = 0
                self.passwordConfirmTextField.alpha = 0
                self.usernameTextField.isHidden = true
                self.passwordConfirmTextField.isHidden = true
//            self.firstNameTextField.isHidden = true
//            self.lastNameTextField.isHidden = true
            })
        })
    }

    @objc func signUpButtonPressed() {
        if passwordConfirmTextField.isHidden == true {
            UIView.animate(withDuration: 0.15, animations: {
                self.loginButton.isHidden = true
                self.cancelButton.isHidden = false
                
                // Set email field to just email for signup
                self.emailTextField.placeholder = L10n.emailAddressPlaceholder
                self.emailTextField.setPlaceHolderTextColor(Stylesheet.Colors.secondaryColor)
            }, completion: { _ in
                UIView.animate(withDuration: 0.15, animations: {
                    self.usernameTextField.alpha = 1
                    self.passwordConfirmTextField.alpha = 1
                    self.usernameTextField.isHidden = false
                    self.passwordConfirmTextField.isHidden = false
//                self.firstNameTextField.isHidden = false
//                self.lastNameTextField.isHidden = false
                })
            })
            return
        }

        guard !emailTextField.isEmpty else {
            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.emailEmpty)
            return
        }

        guard let email = emailTextField.text else { return }
        guard Helpers.isValidEmailAddress(emailAddressString: email) else {
            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.emailWrongFormat)
            return
        }
        
        guard !usernameTextField.isEmpty else {
            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.usernameEmpty)
            return
        }
        
        guard let username = usernameTextField.text else { return }
        // @TODO: Maybe add another check here
//        guard Helpers.isValidEmailAddress(emailAddressString: email) else {
//            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.emailWrongFormat)
//            return
//        }

        guard !passwordTextField.isEmpty else {
            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.passwordEmpty)
            return
        }

        guard let password = passwordTextField.text else { return }
        guard password.length >= 6 else {
            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.passwordNotLongEnough)
            return
        }

        guard !passwordConfirmTextField.isEmpty else {
            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.passwordConfirmEmpty)
            return
        }

        guard let passwordConfirm = passwordConfirmTextField.text else { return }
        guard passwordConfirm == password else {
            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.passwordsDonotMatch)
            return
        }

        // API Login Call
        API.sharedInstance.register(firstName: "", lastName: "", email: email, username: username, password: password, completion: { (success) -> Void in
            if success == false {
                return
            }
            self.navigationController?.popViewController()
        })
    }
}
