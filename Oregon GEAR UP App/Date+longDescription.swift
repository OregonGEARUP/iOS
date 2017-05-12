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

extension Date {
	
	public init(longDescription dateStr: String) {
		self.init()
		self.longDescription = dateStr
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
}
