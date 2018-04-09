//
//  MoreTableViewController.swift
//  SEDaily-IOS
//
//  Created by Keith Holliday on 4/1/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit
import UserNotifications

private let reuseIdentifier = "notifs-reuseIdentifier"

class NotificationsTableViewController: UITableViewController {
    let center = UNUserNotificationCenter.current()
    let options: UNAuthorizationOptions = [.alert, .sound]
    var notificationsSubscribed = false

    required init() {
        super.init(style: .plain)
        self.tabBarItem = UITabBarItem(title: L10n.tabBarNotifications, image: #imageLiteral(resourceName: "mic_stand"), selectedImage: #imageLiteral(resourceName: "mic_stand_selected"))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = UserDefaults.standard
        let subscribed = defaults.object(forKey: "sedaily-notificationsSubscribed") as? Bool
        if subscribed != nil {
            notificationsSubscribed = subscribed!
        }
        
        self.tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)

        self.tableView.rowHeight = UIView.getValueScaledByScreenHeightFor(baseValue: 85)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: reuseIdentifier,
            for: indexPath) as? NotificationTableViewCell else {
                return UITableViewCell()
        }

//        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as NotificationTableViewCell

        // Configure the cell...
        cell.cellLabel.text = "Enable Daily Notifications"
        cell.cellToggle.addTarget(self, action: #selector(switchValueDidChange), for: .touchUpInside)
        
        if notificationsSubscribed {
            cell.cellToggle.setOn(true, animated: true)
        }

        return cell
    }
    
    @objc func switchValueDidChange(sender: UISwitch!) {
        if sender.isOn {
            assignNotifications()
            notificationsSubscribed = true
        } else {
            // cancel
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            notificationsSubscribed = false
        }
        
        let defaults = UserDefaults.standard
        defaults.set(notificationsSubscribed, forKey: "sedaily-notificationsSubscribed")
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
                print("Something went wrong")
                return
            }
            
            self.createNotification()
        })
    }
    
    func createNotification() {
        let date = self.createDate(weekday: 2, hour: 10, minute: 0, year: 2018)
        self.scheduleNotification(at: date, body: "We have new episodes for you!", titles: "Software Daily")
        
        let date2 = self.createDate(weekday: 4, hour: 10, minute: 0, year: 2018)
        self.scheduleNotification(at: date2, body: "We have new episodes for you!", titles: "Software Daily")
        
        let date3 = self.createDate(weekday: 6, hour: 10, minute: 0, year: 2018)
        self.scheduleNotification(at: date3, body: "We have new episodes for you!", titles: "Software Daily")
    }
    
    func createDate(weekday: Int, hour: Int, minute: Int, year: Int) -> Date{
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        components.year = year
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
        
        let request = UNNotificationRequest(identifier: "sedailyNotification", content: content, trigger: trigger)
    
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
