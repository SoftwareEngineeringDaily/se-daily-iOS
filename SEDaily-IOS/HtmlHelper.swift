//
//  HtmlHelper.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 4/25/19.
//  Copyright © 2019 Koala Tea. All rights reserved.
//

import Foundation

class HtmlHelper {
	
	private func removePowerPressPlayerTags(html: String) -> String {
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
	
	private func addStyling(html: String) -> String {
		return "<style type=\"text/css\">body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; } </style>\(html)"
	}
	
	private func addHeightAdjustment(html: String, height: CGFloat) -> String {
		return "<div style='width:100%;height:\(height)px'></div>\(html)"
	}
	
	private func addScaleMeta(html: String) -> String {
		return "<meta name=\"viewport\" content=\"initial-scale=1.0\" />\(html)"
	}
	
}
