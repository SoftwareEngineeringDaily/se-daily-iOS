//
//  Debouncer.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 4/24/19.
//  Copyright © 2019 Altalogy. All rights reserved.
//

import Foundation

class Debouncer: NSObject {
	var callback: (() -> ())
	var delay: Double
	weak var timer: Timer?
	
	init(delay: Double, callback: @escaping (() -> ())) {
		self.delay = delay
		self.callback = callback
	}
	
	func call() {
		timer?.invalidate()
		let nextTimer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(Debouncer.fireNow), userInfo: nil, repeats: false)
		timer = nextTimer
	}
	
	@objc func fireNow() {
		self.callback()
	}
}
