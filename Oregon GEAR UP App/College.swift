//
//  College.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 5/10/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import Foundation


struct College {
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
	
	var applicationDateDescription: String? {
		get {
			if let appDate = applicationDate {
				let dateFormatter = DateFormatter()
				dateFormatter.dateStyle = .long
				dateFormatter.timeStyle = .none
				return dateFormatter.string(from: appDate)
			}
			return nil
		}
		set {
			if let dateString = newValue {
				let dateFormatter = DateFormatter()
				dateFormatter.dateStyle = .long
				dateFormatter.timeStyle = .none
				applicationDate = dateFormatter.date(from: dateString)
			} else {
				applicationDate = nil
			}
		}
	}
	
	var averageNetPriceDescription: String? {
		get {
			if let averageNetPrice = averageNetPrice {
				return NumberFormatter.localizedString(from: NSNumber(value: averageNetPrice), number: .currency)
			}
			return nil
		}
		set {
			if let priceString = newValue {
				let formatter = NumberFormatter()
				formatter.numberStyle = .currency
				if let number = formatter.number(from: priceString) {
					averageNetPrice = number.doubleValue
				} else {
					formatter.numberStyle = .decimal
					averageNetPrice = formatter.number(from: priceString)?.doubleValue
				}
			} else {
				averageNetPrice = nil
			}
		}
	}
	
	var applicationCostDescription: String? {
		get {
			if let applicationCost = applicationCost {
				return NumberFormatter.localizedString(from: NSNumber(value: applicationCost), number: .currency)
			}
			return nil
		}
		set {
			if let costString = newValue {
				let formatter = NumberFormatter()
				if let number = formatter.number(from: costString) {
					applicationCost = number.doubleValue
				} else {
					formatter.numberStyle = .decimal
					applicationCost = formatter.number(from: costString)?.doubleValue
				}
			} else {
				applicationCost = nil
			}
		}
	}
	
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
		
		dictionary["name"] = name
		
		if let applicationDateDescription = applicationDateDescription {
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
