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
	let reminderId: String?
	let reminder: String?
	let reminderDelta: Int?
	
	public init?(date: Date, description: String, reminderId: String? = nil, reminder: String? = nil, reminderDelta: Int? = nil) {
		
		guard let strippedDate = date.stripped() else {
			return nil
		}
		
		self.date = strippedDate
		self.description = description
		self.reminderId = reminderId
		self.reminder = reminder
		self.reminderDelta = reminderDelta
	}
	
	public init?(from dictionary: [String: Any]) {
		
		guard let dateArray = dictionary["date"] as? [String], dateArray.count > 0,
			  let descArray = dictionary["description"] as? [String], descArray.count > 0
		else {
			return nil
		}
		
		// date
		var eventDate: Date?
		for dateStr in dateArray {
			
			if dateStr.hasPrefix("##") && dateStr.hasSuffix("##") {
				let keyRange = NSMakeRange(2, dateStr.count-4)
				let key = (dateStr as NSString).substring(with: keyRange)
				if let replacement = EntryManager.shared.textForKey(key) {
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
			let (newString, good) = stringWithSubstitutions(descStr)
			if good {
				eventDescription = newString
				break
			}
		}
		
		if eventDescription == nil || eventDescription!.isEmpty {
			return nil
		}
			
		description = eventDescription!
		
		
		// reminder fields
		reminderId = dictionary["reminderId"] as? String
		reminder = dictionary["reminder"] as? String
		reminderDelta = dictionary["reminderDelta"] as? Int
	}
}
