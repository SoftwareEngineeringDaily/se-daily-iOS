//
//  Haptics.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 5/21/19.
//  Copyright © 2019 Altalogy All rights reserved.
//
import UIKit

enum FeedbackType {
	case impact
	case notification
	case selection
}

import Foundation

class Haptics {
	static func feedback(_ feedback: FeedbackType) {
		switch feedback {
		case .impact:
			let impact = UIImpactFeedbackGenerator()
			impact.impactOccurred()
		case .notification:
			let notification = UINotificationFeedbackGenerator()
			notification.notificationOccurred(.success)
		case .selection:
			let selection = UISelectionFeedbackGenerator()
			selection.selectionChanged()
		}
	}
}

