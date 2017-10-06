//
//  MyPlanManager.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 5/10/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import UIKit
import UserNotifications


class MyPlanManager {
	
	static let shared = MyPlanManager()
	
	public var colleges: [College]!
	public var scholarships: [Scholarship]!
	public var testResults: TestResults
	public var residency: Residency
	public var calendar: [Date: [CalendarEvent]]
	
	private init() {
		
		colleges = [College]()
		
		if let collegeDictionaries = UserDefaults.standard.array(forKey: "colleges") as? [[String: Any]] {
			for collegeDictionary in collegeDictionaries {
				if let college = College(fromDictionary: collegeDictionary) {
					colleges.append(college)
				}
			}
		}
		
		// make first college if none
		if colleges.count == 0 {
			colleges.append(College(withName: ""))
		}
		
		
		scholarships = [Scholarship]()

		if let scholarshipDictionaries = UserDefaults.standard.array(forKey: "scholarships") as? [[String: Any]] {
			for scholarshipDictionary in scholarshipDictionaries {
				if let scholarship = Scholarship(fromDictionary: scholarshipDictionary) {
					scholarships.append(scholarship)
				}
			}
		}
		
		// make first scholarship if none
		if scholarships.count == 0 {
			scholarships.append(Scholarship(withName: ""))
		}
		
		
		testResults = TestResults()
		
		if let testResultsDictionary = UserDefaults.standard.dictionary(forKey: "testresults") {
			if let results = TestResults(fromDictionary: testResultsDictionary) {
				self.testResults = results
			}
		}
		
		
		residency = Residency()
		
		if let residencyDictionary = UserDefaults.standard.dictionary(forKey: "residency") {
			if let residency = Residency(fromDictionary: residencyDictionary) {
				self.residency = residency
			}
		}
		
		
		// empty calendar will get setup in setupCalendarEvents below
		calendar = [Date: [CalendarEvent]]()
		
		
		checkFirstCollegeName()
		checkFirstScholarshipName()
		checkTestDates()
        
		initializeCalendar()

		
		// serialize out data
		NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationWillResignActive, object: nil, queue: nil) { (note) in
			
			let collegArray = self.colleges.map { (college) -> [String: Any] in
				college.serializeToDictionary()
			}
			UserDefaults.standard.set(collegArray, forKey: "colleges")
			
			let scholarshipArray = self.scholarships.map { (scholarship) -> [String: Any] in
				scholarship.serializeToDictionary()
			}
			UserDefaults.standard.set(scholarshipArray, forKey: "scholarships")
			
			UserDefaults.standard.set(self.testResults.serializeToDictionary(), forKey: "testresults")
			
			UserDefaults.standard.set(self.residency.serializeToDictionary(), forKey: "residency")
			
			self.setupCalendarEvents()
			
			print("persisted My Plan info")
		}
	}
	
	private let firstCollegePlaceholder = "College 1"
	
	public func checkFirstCollegeName() {
		
		guard colleges.count == 1 else {
			return
		}
		
		// determine what college name was entered in the checkpoint
		let cpCollegeName: String
		if let name = UserDefaults.standard.string(forKey: "b2_s3_cp2_i1_text") {
			cpCollegeName = name
		} else {
			cpCollegeName = firstCollegePlaceholder
		}
		
		// fill in any missing pieces of the first college from the checkpoints
		if colleges[0].name == "" || colleges[0].name == firstCollegePlaceholder {
			colleges[0].name = cpCollegeName
		}
		
		if let dateStr = UserDefaults.standard.string(forKey: "b2_s3_cp2_i1_date"),
			colleges[0].applicationDate == nil {
			colleges[0].applicationDate = Date(longDescription: dateStr)
		}
		
		if let priceStr = UserDefaults.standard.string(forKey: "b3citizen_s1_cp3_i1"),
			colleges[0].averageNetPrice == nil {
			colleges[0].averageNetPrice = Double(currencyDescription: priceStr)
		}
		if let priceStr = UserDefaults.standard.string(forKey: "b3undoc_s1_cp3_i1"),
			colleges[0].averageNetPrice == nil  {
			colleges[0].averageNetPrice = Double(currencyDescription: priceStr)
		}
		if let priceStr = UserDefaults.standard.string(forKey: "b3visa_s1_cp3_i1"),
			colleges[0].averageNetPrice == nil  {
			colleges[0].averageNetPrice = Double(currencyDescription: priceStr)
		}
	}
	
	private let firstScholarshipPlaceholder = "Scholarship 1"

	public func checkFirstScholarshipName() {
		
		guard scholarships.count == 1 else {
			return
		}
		
		guard scholarships[0].name == "" || scholarships[0].name == firstScholarshipPlaceholder else {
			return
		}
		
		
		if let scholarshipName = UserDefaults.standard.string(forKey: "b3citizen_s2_cp2_i1_text") {
			
			scholarships[0].name = scholarshipName
			
			if let dateStr = UserDefaults.standard.string(forKey: "b3citizen_s2_cp2_i1_date") {
				scholarships[0].applicationDate = Date(longDescription: dateStr)
			}
			
		} else if let scholarshipName = UserDefaults.standard.string(forKey: "b3undoc_s2_cp2_i1_text") {
			
			scholarships[0].name = scholarshipName
			
			if let dateStr = UserDefaults.standard.string(forKey: "b3undoc_s2_cp2_i1_date") {
				scholarships[0].applicationDate = Date(longDescription: dateStr)
			}
			
		} else if let scholarshipName = UserDefaults.standard.string(forKey: "b3visa_s2_cp2_i1_text") {
			
			scholarships[0].name = scholarshipName
			
			if let dateStr = UserDefaults.standard.string(forKey: "b3visa_s2_cp2_i1_date") {
				scholarships[0].applicationDate = Date(longDescription: dateStr)
			}
			
		} else {
			scholarships[0].name = firstScholarshipPlaceholder
		}
	}
	
	public func checkTestDates() {
		
		if testResults.satDate == nil, let dateStr = UserDefaults.standard.string(forKey: "b4_s1_cp4_i1_date") {
			testResults.satDate = Date(longDescription: dateStr)
		}
		
		if testResults.actDate == nil, let dateStr = UserDefaults.standard.string(forKey: "b4_s1_cp3_i1_date") {
			testResults.actDate = Date(longDescription: dateStr)
		}
	}
	
	public func addCollege(withName name: String) {
		
		colleges.append(College(withName: name))
	}
	
	public func removeCollege(at index: Int) {
		
		colleges.remove(at: index)
	}
	
	public func addScholarship(withName name: String) {
		
		scholarships.append(Scholarship(withName: name))
	}
	
	public func removeScholarship(at index: Int) {
		
		scholarships.remove(at: index)
	}
	
    private let BaseURL = "https://oregongoestocollege.org/mobileApp/json/"
    
    private var eventArray: [[String: Any]]? = nil
    
    private func initializeCalendar() {
        
        // load the calendar info
        let url = URL(string: BaseURL + "calendar.json")!
        let task = URLSession.shared.dataTask(with: url) { (data, reponse, error) -> Void in
            
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("no calendar data found server")
                return
            }
			
			// cache the calendar JSON file data
			if let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first {
				let fileurl = URL(fileURLWithPath: dir).appendingPathComponent("calendar.json")
				try? data.write(to: fileurl)
			}
			
            if let jsonArray = try? JSONSerialization.jsonObject(with: data), let eventArray = jsonArray as? [[String: Any]] {
                self.eventArray = eventArray
            }
            
            self.setupCalendarEvents()
        }
        
        task.resume()
    }
    
	public func setupCalendarEvents() {
		
		calendar = [Date: [CalendarEvent]]()
		
//		if #available(iOS 10.0, *) {
//			UNUserNotificationCenter.current().removeAllDeliveredNotifications()
//			UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//		}
		
		
        let eventArrayToUse: [[String: Any]]
        if self.eventArray != nil {
            eventArrayToUse = self.eventArray!
        } else {
			
            // load the in-app copy of the calendar events
            guard let calendarAsset = NSDataAsset(name: "calendar"),
                let json = try? JSONSerialization.jsonObject(with: calendarAsset.data),
                let eventArray = json as? [[String: Any]] else {
                    
				print("no calendar events available for setup")
				return
            }
            
            eventArrayToUse = eventArray
        }
        
        // build up calendar from events data
        for eventDictionary in eventArrayToUse {
            if let event = CalendarEvent(from: eventDictionary) {
                addEventToCalendar(event)
            }
        }
        
		// add college application deadlines
		for (index, college) in colleges.enumerated() {
			if let date = college.applicationDate {
				
				if let event = CalendarEvent(date: date, description: "\(college.name) application deadline", reminderId: "collegeApp\(index+1)", reminder: "The \(college.name) application is due in one week! Have you submitted it?", reminderDelta: -7) {
					addEventToCalendar(event)
				}
			}
		}
		
		// add scholarship application deadlines
		for (index, scholarship) in scholarships.enumerated() {
			if let date = scholarship.applicationDate {
				
				if let event = CalendarEvent(date: date, description: "\(scholarship.name) application deadline", reminderId: "scholarshipApp\(index+1)", reminder: "The \(scholarship.name) application is due in one week! Have you submitted it?", reminderDelta: -7) {
					addEventToCalendar(event)
				}
			}
		}
		
		// add test dates
		if let date = testResults.actDate {
			
			if let event = CalendarEvent(date: date, description: "ACT test", reminderId: "actTest", reminder: "Good luck on the ACT tomorrow! Get plenty of rest and eat a good breakfast.", reminderDelta: -1) {
				addEventToCalendar(event)
			}
		}
		if let date = testResults.satDate {
			
			if let event = CalendarEvent(date: date, description: "SAT test", reminderId: "satTest", reminder: "Good luck on the SAT tomorrow! Get plenty of rest and eat a good breakfast.", reminderDelta: -1) {
				addEventToCalendar(event)
			}
		}
		
		
//		// TESTING trigger comparison -- looks good!
//		if #available(iOS 10.0, *) {
//			let d1 = Date(timeIntervalSinceNow: 60)
//			let c1 = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: d1)
//			let t1 = UNCalendarNotificationTrigger(dateMatching: c1, repeats: false)
//			
//			let d2 = Date(timeIntervalSinceNow: 90)
//			let c2 = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: d2)
//			let t2 = UNCalendarNotificationTrigger(dateMatching: c2, repeats: false)
//			
//			if t1 == t2 {
//				print("TEST failed: t1 == t2")
//			} else {
//				print("TEST passed: t1 != t2")
//			}
//		}
		
		
		// setup notifications for calendar events
		if #available(iOS 10.0, *) {
			
			UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (pending) in
				
				UNUserNotificationCenter.current().getDeliveredNotifications(completionHandler: { (delivered) in
					
					
//					// TEST
//					let testId = "testreminder"
//					var testFound = false
//					
//					// check to see if the reminder has been delivered, if so do nothing more
//					let foundDelivered = delivered.filter { (deliveredNotification) -> Bool in
//						return deliveredNotification.request.identifier == testId
//					}
//					if foundDelivered.count > 0 {
//						print("test reminder delivered")
//						testFound = true
//					}
//					
//					// check to see if it is pending
//					let foundPending = pending.filter { (pendingNotification) -> Bool in
//						return pendingNotification.identifier == testId
//					}
//					if foundPending.count > 0 {
//						print("test reminder pending")
//						testFound = true
//					}
//					
//					if !testFound {
//						// create new notification
//						let content = UNMutableNotificationContent()
//						content.title = "Test Reminder"
//						content.body = "This is just a test of the reminders."
//						content.sound = UNNotificationSound.default()
//						
//						let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30.0, repeats: false)
//						
//						let request = UNNotificationRequest(identifier: testId, content: content, trigger: trigger)
//						UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
//							if let error = error {
//								print("error creating test notification \(testId): \(error)")
//							} else {
//								print("created test notification: \(testId)")
//							}
//						})
//					}
					
					
					//let gmtOffset = Double(TimeZone.current.secondsFromGMT()) * -1.0
					
					let allEvents = self.calendar.values.flatMap { $0 }
					for event in allEvents {
						
						if  let reminderId = event.reminderId,
							let reminder = event.reminder,
							let delta = event.reminderDelta {
							
							//print("considering: \(reminderId)")
							
							// check to see if the reminder has been delivered, if so do nothing more
							let foundDelivered = delivered.filter { (deliveredNotification) -> Bool in
								return deliveredNotification.request.identifier == reminderId
							}
							if foundDelivered.count > 0 {
								//print("previously delivered: \(reminderId)")
								continue
							}
							
							let tenAM = (10.0 * 60.0 * 60.0)
							let deltaInterval = (Double(delta) * 60.0 * 60.0 * 24.0) + tenAM		// 10am reminders
							let date = event.date.addingTimeInterval(deltaInterval)
							let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
							let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
							
							// check to see if it is pending
							let foundPending = pending.filter { (pendingNotification) -> Bool in
								return pendingNotification.identifier == reminderId
							}
							if foundPending.count > 0 {
								
								// see if it the trigger date has changed, if not nothing more to do
								if foundPending[0].trigger == trigger {
									//print("pending unchanged: \(reminderId)")
									continue
								}
								
								// remove current notification, it will get updated below
								UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderId])
							}
							
							// create new notification
							let content = UNMutableNotificationContent()
							content.title = "Reminder"
							content.body = reminder
							content.sound = UNNotificationSound.default()
							
							let request = UNNotificationRequest(identifier: reminderId, content: content, trigger: trigger)
							UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
								if let error = error {
									print("error creating reminder notification \(reminderId): \(error)")
								} else {
									//print("created reminder notification: \(reminderId)")
								}
							})
						}
					}
				})
			})
		}
	}
	
	private func addEventToCalendar(_ event: CalendarEvent) {
		
//		print(event)
		
		if var events = calendar[event.date] {
			events.append(event)
			calendar[event.date] = events
		} else {
			calendar[event.date] = [event]
		}
	}
	
	public func hasCalendarEventsForDate(_ date: Date) -> Bool {
		
		return calendarEventsForDate(date) != nil
	}
	
	public func calendarEventsForDate(_ date: Date) -> [CalendarEvent]? {
		
		guard let strippedDate = date.stripped() else {
			return nil
		}
		
		return calendar[strippedDate]
	}
}
