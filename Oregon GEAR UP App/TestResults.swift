//
//  TestResults.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 5/10/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import Foundation


struct TestResults {
	
	var actDate: Date?
	var actComposite: Int?
	var actMath: Int?
	var actScience: Int?
	var actReading: Int?
	var actWriting: Int?
	
	var satDate: Date?
	var satTotal: Int?
	var satReadingWriting: Int?
	var satMath: Int?
	var satEssay: Int?
	
	public init() {
		
	}
	
	public init?(fromDictionary dictionary: [String: Any]) {
		
		if let actDateStr = dictionary["actDate"] as? String {
			self.actDate = Date(longDescription: actDateStr)
		}
		if let actComposite = dictionary["actComposite"] as? Int {
			self.actComposite = actComposite
		}
		if let actMath = dictionary["actMath"] as? Int {
			self.actMath = actMath
		}
		if let actScience = dictionary["actScience"] as? Int {
			self.actScience = actScience
		}
		if let actReading = dictionary["actReading"] as? Int {
			self.actReading = actReading
		}
		if let actWriting = dictionary["actWriting"] as? Int {
			self.actWriting = actWriting
		}
		
		if let satDateStr = dictionary["satDate"] as? String {
			self.satDate = Date(longDescription: satDateStr)
		}
		if let satTotal = dictionary["satTotal"] as? Int {
			self.satTotal = satTotal
		}
		if let satReadingWriting = dictionary["satReadingWriting"] as? Int {
			self.satReadingWriting = satReadingWriting
		}
		if let satMath = dictionary["satMath"] as? Int {
			self.satMath = satMath
		}
		if let satEssay = dictionary["satEssay"] as? Int {
			self.satEssay = satEssay
		}
	}
	
	public func serializeToDictionary() -> [String: Any] {
		
		var dictionary = [String: Any]()
		
		if let actDateDescription = actDate?.longDescription {
			dictionary["actDate"] = actDateDescription
		}
		if let actComposite = actComposite {
			dictionary["actComposite"] = actComposite
		}
		if let actMath = actMath {
			dictionary["actMath"] = actMath
		}
		if let actScience = actScience {
			dictionary["actScience"] = actScience
		}
		if let actReading = actReading {
			dictionary["actReading"] = actReading
		}
		if let actWriting = actWriting {
			dictionary["actWriting"] = actWriting
		}
		
		if let satDateDescription = satDate?.longDescription {
			dictionary["satDate"] = satDateDescription
		}
		if let satTotal = satTotal {
			dictionary["satTotal"] = satTotal
		}
		if let satReadingWriting = satReadingWriting {
			dictionary["satReadingWriting"] = satReadingWriting
		}
		if let satMath = satMath {
			dictionary["satMath"] = satMath
		}
		if let satEssay = satEssay {
			dictionary["satEssay"] = satEssay
		}

		return dictionary
	}
}
