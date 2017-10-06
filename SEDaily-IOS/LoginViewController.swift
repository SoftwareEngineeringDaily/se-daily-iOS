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

class LoginViewController: UIViewController {
    
    //    let containerView = UIView()
    let scrollView = UIScrollView()
    let contentView = UIView()
    let topView = UIView()
    let bottomView = UIView()
    
    let imageView = UIImageView()
    let stackView = UIStackView()
    
    let emailTextField = TextField()
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
    
    override func viewWillAppear(_ animated: Bool) {
//        self.navigationBar?.setColors(background: Stylesheet.Colors.base, text: Stylesheet.Colors.white)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        self.navigationBar?.setColors(background: Stylesheet.Colors.white, text: Stylesheet.Colors.base)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLayoutSubviews() {
//        if User.getActiveUser().isLoggedIn() != false {
//            
//            // If so move on to the next screen
////            let vc = CustomTabViewController()
////            self.navigationController?.pushViewController(vc, animated: true)
//            User.logout()
//            self.navigationController?.popViewController()
//        }
    }
    
    func addBottomBorderToView(view: UIView, height: CGFloat, width: CGFloat) {
        let border = CALayer()
        let borderWidth = CGFloat(2.0.calculateHeight())
        border.borderColor = Stylesheet.Colors.secondaryColor.cgColor
        border.frame = CGRect(x: 0, y: height - borderWidth, width:  width, height: height)
        
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
            
            let height = 200.calculateHeight()
            make.height.equalTo(height)
            make.width.equalTo(height)
        }
    }
    
    private func setupTextFields() {
        emailTextField.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(316.calculateWidth())
            make.height.equalTo(36.calculateHeight())
        }
        
        passwordTextField.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(316.calculateWidth())
            make.height.equalTo(36.calculateHeight())
        }
        
        passwordConfirmTextField.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(316.calculateWidth())
            make.height.equalTo(36.calculateHeight())
        }
        
        firstNameTextField.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(316.calculateWidth())
            make.height.equalTo(36.calculateHeight())
        }
        
        lastNameTextField.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(316.calculateWidth())
            make.height.equalTo(36.calculateHeight())
        }
        
        addBottomBorderToView(view: emailTextField, height: 36.calculateHeight(), width: 316.calculateWidth())
        addBottomBorderToView(view: passwordTextField, height: 36.calculateHeight(), width: 316.calculateWidth())
        addBottomBorderToView(view: passwordConfirmTextField, height: 36.calculateHeight(), width: 316.calculateWidth())
        addBottomBorderToView(view: firstNameTextField, height: 36.calculateHeight(), width: 316.calculateWidth())
        addBottomBorderToView(view: lastNameTextField, height: 36.calculateHeight(), width: 316.calculateWidth())
        
        emailTextField.placeholder = NSLocalizedString("EmailAddressPlaceholder", comment: "")
        emailTextField.setPlaceHolderTextColor(Stylesheet.Colors.secondaryColor)
        emailTextField.textColor = Stylesheet.Colors.white
        emailTextField.autocorrectionType = .no
        emailTextField.autocapitalizationType = .none
        
        passwordTextField.placeholder = NSLocalizedString("PasswordPlaceholder", comment: "")
        passwordTextField.setPlaceHolderTextColor(Stylesheet.Colors.secondaryColor)
        passwordTextField.textColor = Stylesheet.Colors.white
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        passwordTextField.isSecureTextEntry = true
        
        passwordConfirmTextField.isHidden = true
        passwordConfirmTextField.placeholder = NSLocalizedString("ConfirmPasswordPlaceholder", comment: "")
        passwordConfirmTextField.textColor = Stylesheet.Colors.white
        passwordConfirmTextField.autocorrectionType = .no
        passwordConfirmTextField.autocapitalizationType = .none
        passwordConfirmTextField.isSecureTextEntry = true
        
        firstNameTextField.isHidden = true
        firstNameTextField.placeholder = NSLocalizedString("FirstNamePlaceholder", comment: "")
        firstNameTextField.textColor = Stylesheet.Colors.white
        firstNameTextField.autocorrectionType = .no
        firstNameTextField.autocapitalizationType = .none
        
        lastNameTextField.isHidden = true
        lastNameTextField.placeholder = NSLocalizedString("LastNamePlaceholder", comment: "")
        lastNameTextField.textColor = Stylesheet.Colors.white
        lastNameTextField.autocorrectionType = .no
        lastNameTextField.autocapitalizationType = .none
    }
    
    private func setupButtons() {
        loginButton.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(94.calculateWidth())
            make.height.equalTo(42.calculateHeight())
        }
        
        cancelButton.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(94.calculateWidth())
            make.height.equalTo(42.calculateHeight())
        }
        
        signUpButton.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(94.calculateWidth())
            make.height.equalTo(42.calculateHeight())
        }
        
        loginButton.setTitle(NSLocalizedString("LoginButtonTitle", comment: ""), for: .normal)
        loginButton.setTitleColor(Stylesheet.Colors.white, for: .normal)
        loginButton.setBackgroundColor(color: Stylesheet.Colors.secondaryColor, forState: .normal)
        loginButton.addTarget(self, action: #selector(self.loginButtonPressed), for: .touchUpInside)
        loginButton.cornerRadius = 4.calculateWidth()
        
        cancelButton.setTitle(NSLocalizedString("CancelButtonTitle", comment: ""), for: .normal)
        cancelButton.setTitleColor(Stylesheet.Colors.white, for: .normal)
        cancelButton.setBackgroundColor(color: Stylesheet.Colors.secondaryColor, forState: .normal)
        cancelButton.addTarget(self, action: #selector(self.cancelButtonPressed), for: .touchUpInside)
        cancelButton.cornerRadius = 4.calculateWidth()
        cancelButton.isHidden = true
        
        signUpButton.setTitle(NSLocalizedString("SignUpButtonTitle", comment: ""), for: .normal)
        signUpButton.setTitleColor(Stylesheet.Colors.white, for: .normal)
        signUpButton.setBackgroundColor(color: Stylesheet.Colors.secondaryColor, forState: .normal)
        signUpButton.addTarget(self, action: #selector(self.signUpButtonPressed), for: .touchUpInside)
        signUpButton.cornerRadius = 4.calculateWidth()
    }
    
    @objc func loginButtonPressed() {
        guard !emailTextField.isEmpty else {
            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.emailEmpty)
            return
        }
        
        guard let email = emailTextField.text else { return }
        guard Helpers.isValidEmailAddress(emailAddressString: email) else {
            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.emailWrongFormat)
            return
        }
        
        guard !passwordTextField.isEmpty else {
            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.passwordEmpty)
            return
        }
        
        guard let password = passwordTextField.text else { return }
        guard password.length >= 6 else {
            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.passwordNotLongEnough)
            return
        }
        
        // API Login Call
        API.sharedInstance.login(username: email, password: password, completion: { (success) -> Void in
            
            if success == false {
//                HUD.hide()
                return
            }
//            HUD.hide({ _ in
            self.navigationController?.popViewController()
//            })
        })
    }
    
    @objc func cancelButtonPressed() {
        loginButton.isHidden = false
        cancelButton.isHidden = true
        passwordConfirmTextField.isHidden = true
        firstNameTextField.isHidden = true
        lastNameTextField.isHidden = true
    }
    
    @objc func signUpButtonPressed() {
        if passwordConfirmTextField.isHidden == true {
            loginButton.isHidden = true
            cancelButton.isHidden = false
            passwordConfirmTextField.isHidden = false
            firstNameTextField.isHidden = false
            lastNameTextField.isHidden = false
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
        API.sharedInstance.register(username: email, password: password, completion: { (success) -> Void in
            
            if success == false {
//                HUD.hide()
                return
            }
//            HUD.hide({ _ in
                self.navigationController?.popViewController()
//            })
        })
    }
}
