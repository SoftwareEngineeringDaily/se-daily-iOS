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
    
    static func hmsFrom(seconds: Int, completion: @escaping (_ hours: Int, _ minutes: Int, _ seconds: Int)->()) {
        
        completion(seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        
    }
    
    static func getStringFrom(seconds: Int) -> String {
        
        return seconds < 10 ? "0\(seconds)" : "\(seconds)"
    }
    
    /*
     A formatter for individual date components used to provide an appropriate
     value for the `startTimeLabel` and `durationLabel`.
     */
    static let timeRemainingFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        
        return formatter
    }()
    
    static func createTimeString(time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, time))
        
        return timeRemainingFormatter.string(from: components as DateComponents)!
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
        }
        catch {
            return nil
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
