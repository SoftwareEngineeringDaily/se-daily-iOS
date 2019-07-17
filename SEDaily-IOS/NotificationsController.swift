//
//  NotificationsController.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 5/9/19.
//  Copyright © 2019 Altalogy. All rights reserved.
//

import UIKit
import UserNotifications


class NotificationsController {
	
	let center = UNUserNotificationCenter.current()
	let options: UNAuthorizationOptions = [.alert, .sound]
	
	var notificationsSubscribed = false
	
	let notificationIndentifier = "sedailyNotification"
	let notificationPrefKey = "sedaily-notificationsSubscribed"
	
	required init() {
		let defaults = UserDefaults.standard
		let subscribed = defaults.object(forKey: notificationPrefKey) as? Bool
		if subscribed != nil {
			notificationsSubscribed = subscribed!
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	

		
		

	
	func assignNotifications () {
		center.getNotificationSettings { (settings) in
			if settings.authorizationStatus != .authorized {
				// Notifications not allowed
				self.requestNotifications()
			} else {
				self.createNotification()
			}
		}
	}
	
	func requestNotifications() {
		center.requestAuthorization(options: options, completionHandler: {
			(granted, error) in
			if !granted {
				return
			}
			
			self.createNotification()
		})
	}
	
	func createNotification() {
		let date = self.createDate(weekday: 2, hour: 10, minute: 0)
		self.scheduleNotification(at: date, body: L10n.mwfNotificationBody, titles: L10n.mwfNotificationTitle)
		
		let date2 = self.createDate(weekday: 4, hour: 10, minute: 0)
		self.scheduleNotification(at: date, body: L10n.mwfNotificationBody, titles: L10n.mwfNotificationTitle)
		
		let date3 = self.createDate(weekday: 6, hour: 10, minute: 0)
		self.scheduleNotification(at: date, body: L10n.mwfNotificationBody, titles: L10n.mwfNotificationTitle)
	}
	
	func createDate(weekday: Int, hour: Int, minute: Int) -> Date{
		var components = DateComponents()
		components.hour = hour
		components.minute = minute
		components.weekday = weekday // sunday = 1 ... saturday = 7
		components.weekdayOrdinal = 10
		components.timeZone = .current
		
		let calendar = Calendar(identifier: .gregorian)
		return calendar.date(from: components)!
	}
	
	//Schedule Notification with weekly bases.
	func scheduleNotification(at date: Date, body: String, titles: String) {
		let triggerWeekly = Calendar.current.dateComponents([.weekday, .hour, .minute, .second], from: date)
		
		let trigger = UNCalendarNotificationTrigger(dateMatching: triggerWeekly, repeats: true)
		
		let content = UNMutableNotificationContent()
		content.title = titles
		content.body = body
		content.sound = UNNotificationSound.default()
		content.categoryIdentifier = "podcast"
		
		let request = UNNotificationRequest(identifier: notificationIndentifier, content: content, trigger: trigger)
		
		UNUserNotificationCenter.current().add(request) {(error) in
			if let error = error {
				print("Uh oh! We had an error: \(error)")
			}
		}
	}
}
