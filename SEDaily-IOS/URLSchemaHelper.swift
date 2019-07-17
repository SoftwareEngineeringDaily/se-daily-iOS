//
//  URLSchemaHelper.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 6/14/19.
//  Copyright © 2019 Koala Tea. All rights reserved.
//

import Foundation

class URLSchemaHelper {
	class func addSchema(url: String)->String {
		var urlString: String = url
		let urlPrefix = urlString.prefix(4)
		if urlPrefix != "http" {
			// Defaulting to http:
			if urlPrefix.prefix(3) == "://" {
				urlString = "http\(url)"
			} else {
				urlString = "http://\(url)"
			}
		}
		return urlString
	}
}
