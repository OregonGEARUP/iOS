//
//  CalendarEvent.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 6/24/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import Foundation


struct CalendarEvent {
	
	let date: Date
	let description: String
	
	public init?(date: Date, description: String) {
		
		guard let strippedDate = date.stripped() else {
			return nil
		}
		
		self.date = strippedDate
		self.description = description
	}
	
	public init?(from dictionary: [String: [String]]) {
		
		guard let dateArray = dictionary["date"], dateArray.count > 0,
			  let descArray = dictionary["description"], descArray.count > 0
		else {
			return nil
		}
		
		// date
		var eventDate: Date?
		for dateStr in dateArray {
			
			if dateStr.hasPrefix("##") && dateStr.hasSuffix("##") {
				let keyRange = NSMakeRange(2, dateStr.characters.count-4)
				let key = (dateStr as NSString).substring(with: keyRange)
				if let replacement = UserDefaults.standard.object(forKey: key) as? String {
					eventDate = Date(longDescription: replacement)
					break
				}
				
			} else {
				eventDate = Date(longDescription: dateStr)
				break
			}
		}
		
		guard let goodDate = eventDate?.stripped() else {
			return nil
		}
		
		date = goodDate
		
		
		// description
		var eventDescription: String?
		for descStr in descArray {
			
			if descStr.hasPrefix("##") && descStr.hasSuffix("##") {
				let keyRange = NSMakeRange(2, descStr.characters.count-4)
				let key = (descStr as NSString).substring(with: keyRange)
				if let replacement = UserDefaults.standard.object(forKey: key) as? String {
					eventDescription = replacement
					break
				}
				
			} else {
				eventDescription = descStr
				break
			}
			
		}
		
		if eventDescription == nil || eventDescription!.isEmpty {
			return nil
		}
			
		description = eventDescription!
	}
}
