//
//  Helpers.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/27/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//


import UIKit
import SwifterSwift
import RealmSwift

extension Helpers {
    static var alert: UIAlertController!
    
    enum Alerts {
        static let error = "Error"
        static let success = "Success"
    }
    
    enum Messages {
        static let emailEmpty = "Email Field Empty"
        static let passwordEmpty = "Password Field Empty"
        static let passwordConfirmEmpty = "Confirm Password Field Empty"
        static let emailWrongFormat = "Invalid Email Format"
        static let passwordNotLongEnough = "Password must be longer than 6 characters"
        static let passwordsDonotMatch = "Password do not match"
        static let firstNameEmpty = "First Name Field Empty"
        static let firstNameNotLongEnough = "First Name must be longer than 1 characters"
        static let lastNameEmpty = "Last Name Field Empty"
        static let lastNameNotLongEnough = "Last Name must be longer than 1 characters"
        static let pleaseLogin = "Please Login"
        static let issueWithUserToken = "Issue with User Token"
        static let noWebsite = "No linked webste."
        static let youMustLogin = "You must login to use this feature."
        static let logoutSuccess = "Successfully Logged Out"
    }
}

class Helpers {
    
    static func alertWithMessage(title: String!, message: String!, completionHandler: (() -> ())? = nil) {
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
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            topController.present(alert, animated: true, completion: nil)
            completionHandler?()
        }
    }
    
    class func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
}

extension Helpers {
    //MARK: Date
    class func formatDate(dateString: String) -> String {
        let startDate = Date(iso8601String: dateString)!
        let startMonth = startDate.monthName()
        let day = startDate.day.string
        let year = startDate.year.string
        return startMonth + " " + day + ", " + year
    }
}

public extension String {
    /// Decodes string with html encoding.
    var htmlDecoded: String {
        guard let encodedData = self.data(using: .utf8) else { return self }
        
        let attributedOptions: [String : Any] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue]
        
        do {
            let attributedString = try NSAttributedString(data: encodedData,
                                                          options: attributedOptions,
                                                          documentAttributes: nil)
            return attributedString.string
        } catch {
            print("Error: \(error)")
            return self
        }
    }
}

class TextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10);
    
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

extension String {
    func convertHtmlSymbols() throws -> String? {
        guard let data = data(using: .utf8) else { return nil }
        
        return try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil).string
    }
}
