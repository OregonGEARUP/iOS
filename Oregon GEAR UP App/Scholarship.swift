//
//  Scholarship.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 5/10/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import Foundation


struct Scholarship {
	var name: String
	var applicationDate: Date?
	var website: String?
	var otherInfo: String?
	var essayDone = false
	var recommendationsDone = false
	var activitiesChartDone = false
	var testsDone = false
	var applicationDone = false
	
	public init(withName name: String) {
		self.name = name
	}
	
	public init?(fromDictionary dictionary: [String: Any]) {
		
		if let name = dictionary["name"] as? String {
			self.name = name
		} else {
			return nil
		}
		
		if let applicationDateStr = dictionary["applicationDate"] as? String {
			let dateFormatter = DateFormatter()
			dateFormatter.dateStyle = .long
			dateFormatter.timeStyle = .none
			self.applicationDate = dateFormatter.date(from: applicationDateStr)
		}
		if let website = dictionary["website"] as? String {
			self.website = website
		}
		if let otherInfo = dictionary["otherInfo"] as? String {
			self.otherInfo = otherInfo
		}
		
		if let essayDone = dictionary["essayDone"] as? Bool,
			let recommendationsDone = dictionary["recommendationsDone"] as? Bool,
			let activitiesChartDone = dictionary["activitiesChartDone"] as? Bool,
			let testsDone = dictionary["testsDone"] as? Bool,
			let applicationDone = dictionary["applicationDone"] as? Bool {
			
			self.essayDone = essayDone
			self.recommendationsDone = recommendationsDone
			self.activitiesChartDone = activitiesChartDone
			self.testsDone = testsDone
			self.applicationDone = applicationDone
		} else {
			return nil
		}
	}
	
	public func serializeToDictionary() -> [String: Any] {
		
		var dictionary = [String: Any]()
		
		dictionary["name"] = name
		
		if let applicationDateDescription = applicationDate?.longDescription {
			dictionary["applicationDate"] = applicationDateDescription
		}
		if let website = website {
			dictionary["website"] = website
		}
		if let otherInfo = otherInfo {
			dictionary["otherInfo"] = otherInfo
		}
		
		dictionary["essayDone"] = essayDone
		dictionary["recommendationsDone"] = recommendationsDone
		dictionary["activitiesChartDone"] = activitiesChartDone
		dictionary["testsDone"] = testsDone
		dictionary["applicationDone"] = applicationDone
		
		return dictionary
	}
}
