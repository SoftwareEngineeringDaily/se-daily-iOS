//
//  LoginViewController.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/27/17.
// 	Modified by Dawid Cedrych on 7/9/18
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import SwifterSwift
import SideMenu
import MBProgressHUD

class LoginViewController: UIViewController {

    let scrollView = UIScrollView()
    let contentView = UIView()
    let topView = UIView()
    let bottomView = UIView()

    let imageView = UIImageView()
    let stackView = UIStackView()

    let emailTextField = InsetTextField()
    let usernameTextField = InsetTextField()
    let passwordTextField = InsetTextField()
    let passwordConfirmTextField = InsetTextField()
    let firstNameTextField = InsetTextField()
    let lastNameTextField = InsetTextField()

    let submitButton = UIButton()
    let toggleButton = UIButton()
	
		let headerLabel = UILabel()
	
    let networkService = API()

    override func viewDidLoad() {
        super.viewDidLoad()

        performLayout()
        self.view.backgroundColor = UIColor.white
        Analytics2.loginFormViewed()
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
        let borderWidth = CGFloat(UIView.getValueScaledByScreenHeightFor(baseValue: 1))
        border.borderColor = Stylesheet.Colors.baseLight.cgColor
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
				setupHeaderLabel()
    }
	
		private func setupHeaderLabel() {
			self.headerLabel.font = UIFont.systemFont(ofSize: 32.0, weight: .bold)
			self.headerLabel.text = L10n.signInHeader
			self.headerLabel.snp.makeConstraints { (make) -> Void in
				make.left.equalTo(emailTextField.snp.left)
			}
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
			
				self.stackView.addArrangedSubview(headerLabel)
        self.stackView.addArrangedSubview(emailTextField)
        self.stackView.addArrangedSubview(usernameTextField)
        self.stackView.addArrangedSubview(passwordTextField)
        self.stackView.addArrangedSubview(passwordConfirmTextField)
        self.stackView.addArrangedSubview(firstNameTextField)
        self.stackView.addArrangedSubview(lastNameTextField)
        self.stackView.addArrangedSubview(submitButton)
        self.stackView.addArrangedSubview(toggleButton)

        stackView.snp.makeConstraints { (make) -> Void in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(toggleButton)
        }
    }

    private func setupImageview() {
        self.scrollView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "logo_subtitle")

        imageView.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(10)
						make.bottom.equalTo(stackView.snp.top)
		
            let height = UIView.getValueScaledByScreenHeightFor(baseValue: 110)
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
        emailTextField.setPlaceHolderTextColor(Stylesheet.Colors.baseLight)
        emailTextField.textColor = Stylesheet.Colors.blackText
        emailTextField.autocorrectionType = .no
        emailTextField.autocapitalizationType = .none
				emailTextField.textAlignment = .left
			
        usernameTextField.isHidden = true
        usernameTextField.placeholder = L10n.usernamePlaceholder
        usernameTextField.setPlaceHolderTextColor(Stylesheet.Colors.baseLight)
        usernameTextField.textColor = Stylesheet.Colors.blackText
        usernameTextField.autocorrectionType = .no
        usernameTextField.autocapitalizationType = .none

        passwordTextField.placeholder = L10n.passwordPlaceholder
        passwordTextField.setPlaceHolderTextColor(Stylesheet.Colors.baseLight)
        passwordTextField.textColor = Stylesheet.Colors.blackText
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        passwordTextField.isSecureTextEntry = true

        passwordConfirmTextField.isHidden = true
        passwordConfirmTextField.placeholder = L10n.confirmPasswordPlaceholder
        passwordConfirmTextField.setPlaceHolderTextColor(Stylesheet.Colors.baseLight)
        passwordConfirmTextField.textColor = Stylesheet.Colors.blackText
        passwordConfirmTextField.autocorrectionType = .no
        passwordConfirmTextField.autocapitalizationType = .none
        passwordConfirmTextField.isSecureTextEntry = true

        firstNameTextField.isHidden = true
        firstNameTextField.placeholder = L10n.firstNamePlaceholder
        firstNameTextField.setPlaceHolderTextColor(Stylesheet.Colors.baseLight)
        firstNameTextField.textColor = Stylesheet.Colors.blackText
        firstNameTextField.autocorrectionType = .no
        firstNameTextField.autocapitalizationType = .none

        lastNameTextField.isHidden = true
        lastNameTextField.placeholder = L10n.lastNamePlaceholder
        lastNameTextField.setPlaceHolderTextColor(Stylesheet.Colors.baseLight)
        lastNameTextField.textColor = Stylesheet.Colors.blackText
        lastNameTextField.autocorrectionType = .no
        lastNameTextField.autocapitalizationType = .none
    }

    private func setupButtons() {
        let width = UIView.getValueScaledByScreenWidthFor(baseValue: 316)
        let height = UIView.getValueScaledByScreenHeightFor(baseValue: 50)
        submitButton.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(width)
            make.height.equalTo(height)
        }

        toggleButton.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(width)
            make.height.equalTo(height)
        }

        submitButton.setTitle(L10n.loginButtonTitle, for: .normal)
        submitButton.setTitleColor(Stylesheet.Colors.white, for: .normal)
        submitButton.setBackgroundColor(color: Stylesheet.Colors.baseLight, forState: .normal)
        submitButton.addTarget(self, action: #selector(self.loginButtonPressed), for: .touchUpInside)
		
				submitButton.layer.shadowColor = Stylesheet.Colors.baseLight.cgColor
				submitButton.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
				submitButton.layer.shadowOpacity = 0.65
				submitButton.layer.shadowRadius = 10.0

        toggleButton.setTitle(L10n.toggleToSignUpButtonTitle, for: .normal)
        toggleButton.setTitleColor(Stylesheet.Colors.secondaryColor, for: .normal)
				toggleButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .medium)
        toggleButton.setBackgroundColor(color: Stylesheet.Colors.clear, forState: .normal)
        toggleButton.addTarget(self, action: #selector(self.toggleButtonPressed), for: .touchUpInside)
			
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
        networkService.login(usernameOrEmail: usernameOrEmail, password: password) { (success) in
            ProgressIndicator.hideBlockingProgress()
            if success == false {
                return
            }
            self.navigationController?.popViewController()
        }
    }
	
		@objc func toggleButtonPressed() {
			if passwordConfirmTextField.isHidden == true {
				UIView.animate(withDuration: 0.15, animations: {
					Analytics2.registrationFormViewed()
					self.submitButton.setTitle(L10n.signUpButtonTitle, for: .normal)
					self.toggleButton.setTitle(L10n.toggleToSignInButtonTitle, for: .normal)
					// Remove login target and add sign up target
					self.submitButton.removeTarget(self, action: #selector(self.loginButtonPressed), for: .touchUpInside)
					self.submitButton.addTarget(self, action: #selector(self.signUpButtonPressed), for: .touchUpInside)
					self.headerLabel.text = L10n.signUpHeader
					// Set email field to just email for signup
					self.emailTextField.placeholder = L10n.emailAddressPlaceholder
					self.emailTextField.setPlaceHolderTextColor(Stylesheet.Colors.baseLight)
				}, completion: { _ in
					UIView.animate(withDuration: 0.15, animations: {
						self.usernameTextField.alpha = 1
						self.passwordConfirmTextField.alpha = 1
						self.usernameTextField.isHidden = false
						self.passwordConfirmTextField.isHidden = false

					})
				})
			} else {
				Analytics2.cancelRegistrationButtonPressed()
				Analytics2.loginFormViewed()
				UIView.animate(withDuration: 0.15, animations: {
					self.submitButton.setTitle(L10n.loginButtonTitle, for: .normal)
					self.toggleButton.setTitle(L10n.toggleToSignUpButtonTitle, for: .normal)
					// Remove sign up target and add login target
					self.submitButton.removeTarget(self, action: #selector(self.signUpButtonPressed), for: .touchUpInside)
					self.submitButton.addTarget(self, action: #selector(self.loginButtonPressed), for: .touchUpInside)
					self.headerLabel.text = L10n.signInHeader
					// Set email field back to "username or email"
					self.emailTextField.placeholder = L10n.usernameOrEmailPlaceholder
					self.emailTextField.setPlaceHolderTextColor(Stylesheet.Colors.baseLight)
				}, completion: { _ in
					UIView.animate(withDuration: 0.15, animations: {
						self.usernameTextField.alpha = 0
						self.passwordConfirmTextField.alpha = 0
						self.usernameTextField.isHidden = true
						self.passwordConfirmTextField.isHidden = true
					})
				})
			}
		}
	
    @objc func signUpButtonPressed() {

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
        networkService.register(firstName: "", lastName: "", email: email, username: username, password: password, completion: { (success) -> Void in
            if success == false {
                return
            }
            self.navigationController?.popViewController()
        })
    }
}

//not sure whether insetTextField effect is desired across the app, so I'm not making it an extension of UITextField
class InsetTextField: UITextField {
	override func textRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.insetBy(dx: 0.0, dy: 5.0)
	}
	override func editingRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.insetBy(dx: 0.0, dy: 5.0)
	}
}
