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
				colleges.append(College(withCollegeName: collegeName))
				
				if let applicationDate = UserDefaults.standard.string(forKey: "b2_s3_cp2_i1_date") {
					colleges[0].applicationDateDescription = applicationDate
				}
				
			} else {
				colleges.append(College(withCollegeName: "my first choice"))
			}
		}
		
		
		// serialize out colleges
		NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationWillResignActive, object: nil, queue: nil) { (note) in
			
			let collegArray = self.colleges.map { (college) -> [String: Any] in
				college.serializeToDictionary()
			}
			
			UserDefaults.standard.set(collegArray, forKey: "colleges")
		}
	}
}
