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
	
	private init() {
		
		colleges = [College]()
		
		if let collegeDictionaries = UserDefaults.standard.array(forKey: "colleges") as? [[String: Any]] {
			for collegeDictionary in collegeDictionaries {
				if let college = College(fromDictionary: collegeDictionary) {
					colleges.append(college)
				}
			}
		}
		
		// try to make first college from the checkpoint entries
		if colleges.count == 0 {
			
			if let collegeName = UserDefaults.standard.string(forKey: "b2_s3_cp2_i1_text") {
				colleges.append(College(withName: collegeName))
				
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
				colleges.append(College(withName: "my first choice"))
			}
		}
		
		
		scholarships = [Scholarship]()

		if let scholarshipDictionaries = UserDefaults.standard.array(forKey: "scholarships") as? [[String: Any]] {
			for scholarshipDictionary in scholarshipDictionaries {
				if let scholarship = Scholarship(fromDictionary: scholarshipDictionary) {
					scholarships.append(scholarship)
				}
			}
		}
		
		if scholarships.count == 0,
			let scholarshipName = UserDefaults.standard.string(forKey: "b3citizen_s3_cp2_i1_text") {
			
			scholarships.append(Scholarship(withName: scholarshipName))
			
			if let dateStr = UserDefaults.standard.string(forKey: "b3citizen_s3_cp2_i1_date") {
				scholarships[0].applicationDate = Date(longDescription: dateStr)
			}
		}
		
		if scholarships.count == 0,
			let scholarshipName = UserDefaults.standard.string(forKey: "b3undoc_s3_cp2_i1_text") {
			
			scholarships.append(Scholarship(withName: scholarshipName))
			
			if let dateStr = UserDefaults.standard.string(forKey: "b3undoc_s3_cp2_i1_date") {
				scholarships[0].applicationDate = Date(longDescription: dateStr)
			}
		}
		
		if scholarships.count == 0,
			let scholarshipName = UserDefaults.standard.string(forKey: "b3visa_s3_cp2_i1_text") {
			
			scholarships.append(Scholarship(withName: scholarshipName))
			
			if let dateStr = UserDefaults.standard.string(forKey: "b3visa_s3_cp2_i1_date") {
				scholarships[0].applicationDate = Date(longDescription: dateStr)
			}
		}
		
		if scholarships.count == 0 {
			scholarships.append(Scholarship(withName: "my first scholarship"))
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
}
