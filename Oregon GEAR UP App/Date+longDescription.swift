//
//  Date+longDescription.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 5/11/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import Foundation


fileprivate var longDateFormatter: DateFormatter = {
	let formatter = DateFormatter()
	formatter.dateStyle = .long
	formatter.timeStyle = .none
	return formatter
}()

fileprivate var monthYearFormatter: DateFormatter = {
	let formatter = DateFormatter()
	formatter.setLocalizedDateFormatFromTemplate("MMMM YYYY")
	return formatter
}()

fileprivate var yearFormatter: DateFormatter = {
	let formatter = DateFormatter()
	formatter.setLocalizedDateFormatFromTemplate("YYYY")
	return formatter
}()

extension Date {
	
	public init?(longDescription dateStr: String) {
		self.init()
		
		if let date = longDateFormatter.date(from: dateStr) {
			self = date
		} else {
			return nil
		}
	}
	
	public var longDescription: String {
		get {
			return longDateFormatter.string(from: self)
		}
		set {
			if let date = longDateFormatter.date(from: newValue) {
				self = date
			}
		}
	}
	public var monthYearDescription: String {
		get {
			return monthYearFormatter.string(from: self)
		}
	}
	public var yearDescription: String {
		get {
			return yearFormatter.string(from: self)
		}
	}
}
