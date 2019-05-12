//
//  Helpers.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/27/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import SwifterSwift

extension Helpers {
    static var alert: UIAlertController!

    enum Alerts {
        static let error = L10n.genericError
        static let success = L10n.genericSuccess
    }

    enum Messages {
        static let emailEmpty = L10n.alertMessageEmailEmpty
        static let usernameEmpty = L10n.alertMessageUsernameEmpty
        static let passwordEmpty = L10n.alertMessagePasswordEmpty
        static let passwordConfirmEmpty = L10n.alertMessagePasswordConfirmEmpty
        static let emailWrongFormat = L10n.alertMessageEmailWrongFormat
        static let passwordNotLongEnough = L10n.alertMessagePasswordNotLongEnough
        static let passwordsDonotMatch = L10n.alertMessagePasswordsDonotMatch
        static let firstNameEmpty = L10n.alertMessageFirstNameEmpty
        static let firstNameNotLongEnough = L10n.alertMessageFirstNameNotLongEnough
        static let lastNameEmpty = L10n.alertMessageLastNameEmpty
        static let lastNameNotLongEnough = L10n.alertMessageLastNameNotLongEnough
        static let pleaseLogin = L10n.alertMessagePleaseLogin
        static let issueWithUserToken = L10n.alertMessageIssueWithUserToken
        static let youMustLogin = L10n.alertMessageYouMustLogin
        static let logoutSuccess = L10n.alertMessageLogoutSuccess
    }
}

class Helpers {
    static func alertWithMessage(title: String!, message: String!, completionHandler: (() -> Void)? = nil) {
        //@TODO: Guard if there's already an alert message
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            guard !(topController is UIAlertController) else {
                // There's already a alert preseneted
                return
            }

            alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: L10n.genericOkay, style: UIAlertActionStyle.default, handler: nil))
            topController.present(alert, animated: true, completion: nil)
            completionHandler?()
        }
    }
    
    static func alertWithMessageCustomAction(title: String!, message: String!, actionTitle: String, completionHandler: (() -> Void)? = nil) {
        //@TODO: Guard if there's already an alert message
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            guard !(topController is UIAlertController) else {
                // There's already a alert preseneted
                return
            }
            
            alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (_) in
                completionHandler?()
            }))
            topController.present(alert, animated: true, completion: nil)
        }
    }

    class func isValidEmailAddress(emailAddressString: String) -> Bool {

        var returnValue = true
        let emailRegEx = "^[A-Z0-9a-z._-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"

        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))

            if results.count == 0 {
                returnValue = false
            }

        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }

        return  returnValue
    }

    static func hmsFrom(seconds: Int, completion: @escaping (_ hours: Int, _ minutes: Int, _ seconds: Int) -> Void) {

        completion(seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)

    }

    static func getStringFrom(seconds: Int) -> String {

        return seconds < 10 ? "0\(seconds)" : "\(seconds)"
    }

	

	static func createTimeString(time: Float, units: NSCalendar.Unit ) -> String {
		/*
		A formatter for individual date components used to provide an appropriate
		value for the `startTimeLabel`, `durationLabel` and `timeLeft label`.
		*/
		let timeRemainingFormatter: DateComponentsFormatter = {
			let formatter = DateComponentsFormatter()
			formatter.zeroFormattingBehavior = .pad
			formatter.allowedUnits = units
			
			return formatter
		}()
		let components = NSDateComponents()
		components.second = Int(max(0.0, time))

		return timeRemainingFormatter.string(from: components as DateComponents)!
	}
}

extension Helpers {
    class func formatDate(dateString: String) -> String {
        let startDate = Date(iso8601String: dateString)!
        let startMonth = startDate.monthName()
        let day = startDate.day.string
        let year = startDate.year.string
        return startMonth + " " + day + ", " + year
    }
	
	class func getScreenWidth() -> CGFloat {
		return UIScreen.main.bounds.width
	}
    
    class func getEpisodeCellHeight() -> CGFloat {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                return 200
            default:
                return 250
            }
        }
        return 250
    }
}

import SwiftSoup

public extension String {
    // Decodes string with html encoding.
    // This is very fast
    var htmlDecoded: String {
        do {
            let html = self
            let doc: Document = try SwiftSoup.parse(html)
            return try doc.text()
        } catch {
            return self
        }
    }
}

extension String {
    // Decode HTML while keeping attributes like "/n" and bulleted lists
    // This is a bit slow
    var htmlDecodedWithSomeEntities: String? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
            NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue
        ]
        do {

            let attributedString = try NSAttributedString(data: data, options: options, documentAttributes: nil)
            return attributedString.string
        } catch {
            return nil
        }
    }
}

class TextField: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}
