//
//  MyPlanManager.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 5/10/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import Foundation


class MyPlanManager {
	
	static let shared = MyPlanManager()
	
	public var colleges: [College]!
	public var scholarships: [Scholarship]!
	public var testResults: TestResults
	public var residency: Residency
	public var calendar: [DateComponents: [CalendarEvent]]
	
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
		
		
		calendar = [DateComponents: [CalendarEvent]]()
		
		// TEMPORARY data for calendar
		let date1 = Calendar.current.date(from: DateComponents(year: 1962, month: 7, day: 11))!
		let date1a = Calendar.current.date(from: DateComponents(year: 1962, month: 7, day: 11))!
		calendar[DateComponents(month: 7, day: 11)] = [CalendarEvent(date: date1, description: "Cathy's Birthday! With more text to test that it will wrap onto multiple lines.", key: nil), CalendarEvent(date: date1a, description: "Another event for testing", key: nil)]
		let date2 = Calendar.current.date(from: DateComponents(year: 1994, month: 9, day: 30))!
		calendar[DateComponents(month: 9, day: 30)] = [CalendarEvent(date: date2, description: "Kristen's Birthday!", key: nil)]
		let date3 = Calendar.current.date(from: DateComponents(year: 1962, month: 12, day: 22))!
		calendar[DateComponents(month: 12, day: 22)] = [CalendarEvent(date: date3, description: "Steve's Birthday!", key: nil)]
		
		
		
		checkFirstCollegeName()
		checkFirstScholarshipName()
		
		
		
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
	
	public func hasCalendarEventsForDate(_ date: Date) -> Bool {
		
		return calendarEventsForDate(date) != nil
	}
	
	public func calendarEventsForDate(_ date: Date) -> [CalendarEvent]? {
		
		let comps = Calendar.current.dateComponents(Set([.month, .day]), from: date)
		return calendar[comps]
	}
}
