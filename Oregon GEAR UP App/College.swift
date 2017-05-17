//
//  College.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 5/10/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import Foundation


struct College {
	var uuid: String
	var name: String
	var applicationDate: Date?
	var averageNetPrice: Double?
	var applicationCost: Double?
	var essayDone = false
	var recommendationsDone = false
	var activitiesChartDone = false
	var testsDone = false
	var addlFinancialAidDone = false
	var addlScholarshipDone = false
	var feeDeferralDone = false
	var applicationDone = false
	
	var username: String? {
		get {
			return KeychainWrapper.standard.string(forKey: uuid+"_username")
		}
		set {
			if let username = newValue {
				KeychainWrapper.standard.set(username, forKey: uuid+"_username")
			} else {
				KeychainWrapper.standard.removeObject(forKey: uuid+"_username")
			}
		}
	}
	
	var password: String? {
		get {
			return KeychainWrapper.standard.string(forKey: uuid+"_password")
		}
		set {
			if let username = newValue {
				KeychainWrapper.standard.set(username, forKey: uuid+"_password")
			} else {
				KeychainWrapper.standard.removeObject(forKey: uuid+"_password")
			}
		}
	}
	
	public init(withName name: String) {
		self.uuid = UUID().uuidString
		self.name = name
	}
	
	public init?(fromDictionary dictionary: [String: Any]) {
		
		if let uuid = dictionary["uuid"] as? String,
			let name = dictionary["name"] as? String {
			self.uuid = uuid
			self.name = name
		} else {
			return nil
		}
		
		if let applicationDateStr = dictionary["applicationDate"] as? String {
			self.applicationDate = Date(longDescription: applicationDateStr)
		}
		if let averageNetPrice = dictionary["averageNetPrice"] as? Double {
			self.averageNetPrice = averageNetPrice
		}
		if let applicationCost = dictionary["applicationCost"] as? Double {
			self.applicationCost = applicationCost
		}
		
		if let essayDone = dictionary["essayDone"] as? Bool,
			let recommendationsDone = dictionary["recommendationsDone"] as? Bool,
			let activitiesChartDone = dictionary["activitiesChartDone"] as? Bool,
			let testsDone = dictionary["testsDone"] as? Bool,
			let addlFinancialAidDone = dictionary["addlFinancialAidDone"] as? Bool,
			let addlScholarshipDone = dictionary["addlScholarshipDone"] as? Bool,
			let feeDeferralDone = dictionary["feeDeferralDone"] as? Bool,
			let applicationDone = dictionary["applicationDone"] as? Bool {
			
			self.essayDone = essayDone
			self.recommendationsDone = recommendationsDone
			self.activitiesChartDone = activitiesChartDone
			self.testsDone = testsDone
			self.addlFinancialAidDone = addlFinancialAidDone
			self.addlScholarshipDone = addlScholarshipDone
			self.feeDeferralDone = feeDeferralDone
			self.applicationDone = applicationDone
		} else {
			return nil
		}
	}
	
	public func serializeToDictionary() -> [String: Any] {
		
		var dictionary = [String: Any]()
		
		dictionary["uuid"] = uuid
		dictionary["name"] = name
		
		if let applicationDateDescription = applicationDate?.longDescription {
			dictionary["applicationDate"] = applicationDateDescription
		}
		if let averageNetPrice = averageNetPrice {
			dictionary["averageNetPrice"] = averageNetPrice
		}
		if let applicationCost = applicationCost {
			dictionary["applicationCost"] = applicationCost
		}
		
		dictionary["essayDone"] = essayDone
		dictionary["recommendationsDone"] = recommendationsDone
		dictionary["activitiesChartDone"] = activitiesChartDone
		dictionary["testsDone"] = testsDone
		dictionary["addlFinancialAidDone"] = addlFinancialAidDone
		dictionary["addlScholarshipDone"] = addlScholarshipDone
		dictionary["feeDeferralDone"] = feeDeferralDone
		dictionary["applicationDone"] = applicationDone
		
		return dictionary
	}
}
