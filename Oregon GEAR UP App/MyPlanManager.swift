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
		setupCalendarEvents()

		
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
			
			print("persisted My Plan info")
		}
	}
	
	private let firstNamePlaceholder = "my first choice"
	
	public func checkFirstCollegeName() {
		
		guard colleges.count == 1 else {
			return
		}
		
		guard colleges[0].name == "" || colleges[0].name == firstNamePlaceholder else {
			return
		}
		
		
		if let collegeName = UserDefaults.standard.string(forKey: "b2_s3_cp2_i1_text") {
			colleges[0].name = collegeName
			
			if let dateStr = UserDefaults.standard.string(forKey: "b2_s3_cp2_i1_date") {
				colleges[0].applicationDate = Date(longDescription: dateStr)
			}
			
			if let priceStr = UserDefaults.standard.string(forKey: "b3citizen_s1_cp3_i1") {
				colleges[0].averageNetPrice = Double(priceStr)
			}
			if let priceStr = UserDefaults.standard.string(forKey: "b3undoc_s1_cp3_i1") {
				colleges[0].averageNetPrice = Double(priceStr)
			}
			if let priceStr = UserDefaults.standard.string(forKey: "b3visa_s1_cp3_i1") {
				colleges[0].averageNetPrice = Double(priceStr)
			}
			
		} else {
			colleges[0].name = firstNamePlaceholder
		}
	}
	
	public func checkFirstScholarshipName() {
		
		guard scholarships.count == 1 else {
			return
		}
		
		guard scholarships[0].name == "" || scholarships[0].name == firstNamePlaceholder else {
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
			scholarships[0].name = firstNamePlaceholder
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
	
	public func setupCalendarEvents() {
		
		calendar = [Date: [CalendarEvent]]()
		
//		if #available(iOS 10.0, *) {
//			UNUserNotificationCenter.current().removeAllDeliveredNotifications()
//			UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//		}
		
		
		// build up calendar from JSON data file
		if	let calendarAsset = NSDataAsset(name: "calendar"),
			let json = try? JSONSerialization.jsonObject(with: calendarAsset.data),
			let eventArray = json as? [[String: Any]] {
			
			for eventDictionary in eventArray {
				if let event = CalendarEvent(from: eventDictionary) {
					addEventToCalendar(event)
				}
			}
		}
		
		// add college application deadlines
		for college in colleges {
			if let date = college.applicationDate {
				
				// TODO: add reminder info to event
				if let event = CalendarEvent(date: date, description: "\(college.name) application deadline") {
					addEventToCalendar(event)
				}
			}
		}
		
		// add scholarship application deadlines
		for scholarship in scholarships {
			if let date = scholarship.applicationDate {
				
				// TODO: add reminder info to event
				if let event = CalendarEvent(date: date, description: "\(scholarship.name) application deadline") {
					addEventToCalendar(event)
				}
			}
		}
		
		// add test dates
		if let date = testResults.actDate {
			
			// TODO: add reminder info to event
			if let event = CalendarEvent(date: date, description: "ACT test") {
				addEventToCalendar(event)
			}
		}
		if let date = testResults.satDate {
			
			// TODO: add reminder info to event
			if let event = CalendarEvent(date: date, description: "SAT test") {
				addEventToCalendar(event)
			}
		}
		
		
		// setup notifications for calendar events
		if #available(iOS 10.0, *) {
			
			UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (pending) in
				
				UNUserNotificationCenter.current().getDeliveredNotifications(completionHandler: { (delivered) in
					
					let allEvents = self.calendar.values.flatMap { $0 }
					for event in allEvents {
						
						if  let reminderId = event.reminderId,
							let reminder = event.reminder,
							let delta = event.reminderDelta {
							
							// check to see if the reminder has been delivered, if so do nothing more
							let foundDelivered = delivered.filter { (deliveredNotification) -> Bool in
								return deliveredNotification.request.identifier == reminderId
							}
							if foundDelivered.count > 0 {
								continue
							}
							
							
							let deltaInterval = (Double(delta) * 60.0 * 60.0 * 24.0) + ((14.0 + 7.0) * 60.0 * 60.0)		// 10am reminders
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
									print("error creating reminder notification: \(error)")
								} else {
									print("created reminder notification: \(request)")
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
		
//		// setup reminder
//		if #available(iOS 10.0, *) {
//			if  let reminderId = event.reminderId,
//				let reminder = event.reminder,
//				let delta = event.reminderDelta {
//				
//				let deltaInterval = (Double(delta) * 60.0 * 60.0 * 24.0) + (10.0 * 60.0 * 60.0)		// 10am reminders
//				let date = event.date.addingTimeInterval(deltaInterval)
//				let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
//				let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
//				
//				let content = UNMutableNotificationContent()
//				content.title = "Reminder"
//				content.body = reminder
//				content.sound = UNNotificationSound.default()
//				
//				let request = UNNotificationRequest(identifier: reminderId, content: content, trigger: trigger)
//				UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
//					if let error = error {
//						print("error creating reminder notification: \(error)")
//					}
//				})
//			}
//		}
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
