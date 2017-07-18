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
    let signUpButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        performLayout()
        self.view.backgroundColor = Stylesheet.Colors.base
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationBar?.setColors(background: Stylesheet.Colors.base, text: Stylesheet.Colors.white)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationBar?.setColors(background: Stylesheet.Colors.white, text: Stylesheet.Colors.base)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLayoutSubviews() {
        if User.getActiveUser().isLoggedIn() != false {
            
            // If so move on to the next screen
            let vc = CustomTabViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
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
        
        stackView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.view.center)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(signUpButton)
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
        
        emailTextField.placeholder = "Email"
        emailTextField.textColor = Stylesheet.Colors.white
        emailTextField.autocorrectionType = .no
        emailTextField.autocapitalizationType = .none
        
        passwordTextField.placeholder = "Password"
        passwordTextField.textColor = Stylesheet.Colors.white
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        passwordTextField.isSecureTextEntry = true
        
        passwordConfirmTextField.isHidden = true
        passwordConfirmTextField.placeholder = "Confirm Password"
        passwordConfirmTextField.textColor = Stylesheet.Colors.white
        passwordConfirmTextField.autocorrectionType = .no
        passwordConfirmTextField.autocapitalizationType = .none
        passwordConfirmTextField.isSecureTextEntry = true
        
        firstNameTextField.isHidden = true
        firstNameTextField.placeholder = "First Name"
        firstNameTextField.textColor = Stylesheet.Colors.white
        firstNameTextField.autocorrectionType = .no
        firstNameTextField.autocapitalizationType = .none
        
        lastNameTextField.isHidden = true
        lastNameTextField.placeholder = "Last Name"
        lastNameTextField.textColor = Stylesheet.Colors.white
        lastNameTextField.autocorrectionType = .no
        lastNameTextField.autocapitalizationType = .none
    }
    
    private func setupButtons() {
        loginButton.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(94.calculateWidth())
            make.height.equalTo(42.calculateHeight())
        }
        
        signUpButton.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(94.calculateWidth())
            make.height.equalTo(42.calculateHeight())
        }
        
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(Stylesheet.Colors.white, for: .normal)
        loginButton.setBackgroundColor(color: Stylesheet.Colors.secondaryColor, forState: .normal)
        loginButton.addTarget(self, action: #selector(self.loginButtonPressed), for: .touchUpInside)
        loginButton.cornerRadius = 4.calculateWidth()
        
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.setTitleColor(Stylesheet.Colors.white, for: .normal)
        signUpButton.setBackgroundColor(color: Stylesheet.Colors.secondaryColor, forState: .normal)
        signUpButton.addTarget(self, action: #selector(self.signUpButtonPressed), for: .touchUpInside)
        signUpButton.cornerRadius = 4.calculateWidth()
    }
    
    func loginButtonPressed() {
        passwordConfirmTextField.isHidden = true
        firstNameTextField.isHidden = true
        lastNameTextField.isHidden = true
        
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
//        HUD.show(.systemActivity)
//        API.sharedInstance.login(email: email, password: password, completion: { (success) -> Void in
//            
//            if success == false {
//                HUD.hide()
//                return
//            }
//            HUD.hide()
//            // Completed so present Tab controller
//            let vc = CustomTabViewController()
//            self.navigationController?.pushViewController(vc, animated: true)
//        })
    }
    
    func signUpButtonPressed() {
        if passwordConfirmTextField.isHidden == true {
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
        
        guard !firstNameTextField.isEmpty else {
            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.firstNameEmpty)
            return
        }
        
        guard let firstName = firstNameTextField.text else { return }
        guard firstName.length >= 2 else {
            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.lastNameNotLongEnough)
            return
        }
        
        guard !lastNameTextField.isEmpty else {
            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.lastNameEmpty)
            return
        }
        
        guard let lastName = lastNameTextField.text else { return }
        guard lastName.length >= 2 else {
            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.lastNameNotLongEnough)
            return
        }
        
        // API Login Call
//        HUD.show(.systemActivity)
//        API.sharedInstance.register(firstName: firstName, lastName: lastName, email: email, password: password, completion: { (success) -> Void in
//            
//            if success == false {
//                HUD.hide()
//                return
//            }
//            
//            // Completed so present Tab controller
//            let vc = CustomTabViewController()
//            self.navigationController?.pushViewController(vc, animated: true)
//        })
    }
}
