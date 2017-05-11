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
	
	private init() {
		
		colleges = [College]()
		scholarships = [Scholarship]()
		
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
				
				if let applicationDate = UserDefaults.standard.string(forKey: "b2_s3_cp2_i1_date") {
					colleges[0].applicationDateDescription = applicationDate
				}
				
			} else {
				colleges.append(College(withName: "my first choice"))
			}
		}
		
		if let scholarshipDictionaries = UserDefaults.standard.array(forKey: "scholarships") as? [[String: Any]] {
			for scholarshipDictionary in scholarshipDictionaries {
				if let scholarship = Scholarship(fromDictionary: scholarshipDictionary) {
					scholarships.append(scholarship)
				}
			}
		}
		
		if scholarships.count == 0 {
			scholarships.append(Scholarship(withName: "my first scholarship"))
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
