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
	
	public init?(from dictionary: [String: [String]]) {
		
		guard let dateArray = dictionary["date"], dateArray.count > 0,
			  let descArray = dictionary["description"], descArray.count > 0
		else {
			return nil
		}
		
		if dateArray[0].hasPrefix("##") || dateArray[0].hasSuffix("##") {
			
			// TODO: add support for keyed dates
			
			return nil
		}
		
		date = Date(longDescription: dateArray[0])
		
		if descArray[0].hasPrefix("##") || descArray[0].hasSuffix("##") {
			
			// TODO: add support for keyed descriptions
			
			return nil
		}
		
		description = descArray[0]
	}
}
