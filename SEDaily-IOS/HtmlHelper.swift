//
//  HtmlHelper.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 4/25/19.
//  Copyright © 2019 Altalogy. All rights reserved.
//

import Foundation
import UIKit

class HtmlHelper {
	
	class func getMeta(html:String)->String {
		return removePowerPressPlayerTags(html: html)
	}
	
	class func removePowerPressPlayerTags(html: String) -> String {
		var modifiedHtml = html
		guard let powerPressPlayerRange = modifiedHtml.range(of: "<!--powerpress_player-->") else {
			return modifiedHtml
		}
		modifiedHtml.removeSubrange(powerPressPlayerRange)
		
		/////////////////////////
		guard let divStartRange = modifiedHtml.range(of: "<div class=\"powerpress_player\"") else {
			return modifiedHtml
		}
		guard let divEndRange = modifiedHtml.range(of: "</div>") else {
			return modifiedHtml
		}
		modifiedHtml.removeSubrange(divStartRange.lowerBound..<divEndRange.upperBound)
		
		/////////////////////////
		guard let pStartRange = modifiedHtml.range(of: "<p class=\"powerpress_links powerpress_links_mp3\">") else {
			return modifiedHtml
		}
		guard let pEndRange = modifiedHtml.range(of: "</p>") else {
			return modifiedHtml
		}
		modifiedHtml.removeSubrange(pStartRange.lowerBound..<pEndRange.upperBound)
		return modifiedHtml
	}
	
	class func removeImage(html: String) -> String {
		var modifiedHtml = html
		guard let divStartRange = modifiedHtml.range(of: "<img") else {
			return modifiedHtml
		}
		guard let divEndRange = modifiedHtml.range(of: "data-recalc-dims=\"1\" />") else {
			return modifiedHtml
		}
		modifiedHtml.removeSubrange(divStartRange.lowerBound..<divEndRange.upperBound)
		
		return modifiedHtml
	}
	
	class func addStyling(html: String) -> String {
		
		let margin = UIView.getValueScaledByScreenWidthFor(baseValue: 15.0)
		let fontSize = UIView.getValueScaledByScreenWidthFor(baseValue: 15.0)
		
		return "<head><link href=\"https://fonts.googleapis.com/css?family=Open+Sans\" rel=\"stylesheet\"></head><style type=\"text/css\">body { font-family: 'Open Sans', sans-serif; font-size: \(fontSize)px; margin: \(margin) } a { color: #714CFE } </style>\(html)"
	}
	
	class func addWidthAdjustment(html: String) -> String {
		return "<div style='width:100vw;'></div>\(html)"
	}
	
	class func addScaleMeta(html: String) -> String {
		return "<meta name=\"viewport\" content=\"initial-scale=1.0\" />\(html)"
	}
	
	
	class func getHTML(html: String)-> String {
		return removeImage(html: addScaleMeta(html: addStyling(html: removePowerPressPlayerTags(html: html))))
	}
	
}

