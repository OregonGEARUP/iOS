//
//  Double+currencyDescription.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 5/16/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import Foundation


extension Double {
	
	public init(currencyDescription currencyStr: String) {
		self.init()
		self.currencyDescription = currencyStr
	}
	
	public var currencyDescription: String {
		get {
			return NumberFormatter.localizedString(from: NSNumber(value: self), number: .currency)
		}
		set {
			let formatter = NumberFormatter()
			formatter.numberStyle = .currency
			if let number = formatter.number(from: newValue) {
				self = number.doubleValue
			} else {
				formatter.numberStyle = .decimal
				if let number = formatter.number(from: newValue) {
					self = number.doubleValue
				}
			}
		}
	}
}
