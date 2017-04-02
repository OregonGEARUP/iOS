//
//  Checkpoint.swift
//  Oregon GEAR UP App
//
//  Created by Max MacEachern on 11/28/16.
//  Copyright © 2016 Oregon GEAR UP. All rights reserved.
//

import Foundation

enum EntryType: String {
    case fieldEntry = "field"
    case radioEntry = "radio"
	case dateOnlyEntry = "dateOnly"
	case dateAndTextEntry = "dateAndText"
    case checkboxEntry = "checkbox"
	case infoEntry = "info"
	case routeEntry = "route"
}

struct Instance {
	let identifier: String
    let prompt: String
	let placeholder: String
	
	var promptSubstituted: String { return stringWithSubstitutions(prompt) }
	var placeholderSubstituted: String { return stringWithSubstitutions(placeholder) }
}

struct Checkpoint {
	let identifier: String
	let required: Bool
    let title: String
    let description: String
    let moreInfo: String?
	let moreInfoURL: URL?
	
	let type: EntryType
	let instances: [Instance]
	
	let criteria: [String: String]?
	let filename: String?
	
	var entryTypeKey: String {
		return type.rawValue
	}
	
	var meetsCriteria: Bool {
		
		var meets = true
		if let criteria = criteria {
			
			// check to see that all criteria are met
			for key in criteria.keys {
				if let obj = UserDefaults.standard.object(forKey: key) {
					let objStr = String(describing: obj).lowercased()
					let value = criteria[key]?.lowercased()
					meets = meets && (objStr == value)
				} else {
					meets = false
				}
				
				if !meets {
					break
				}
			}
			
		}
		
		// make sure we have a route destination
		if meets && filename == nil {
			meets = false
		}
		
		return meets
	}
	
	var titleSubstituted: String { return stringWithSubstitutions(title) }
	var descriptionSubstituted: String { return stringWithSubstitutions(description) }
	var moreInfoSubstituted: String? { return (moreInfo != nil ? stringWithSubstitutions(moreInfo!) : nil) }
}


private var re: NSRegularExpression {
	return try! NSRegularExpression(pattern: "##[^(##)]+##", options: [])
}

private func stringWithSubstitutions(_ string: String) -> String {
	
	let matches = re.matches(in: string, options: [], range: NSMakeRange(0, string.characters.count))
	
	var newString = string
	for match in matches {
		let keyRange = NSMakeRange(match.range.location+2, match.range.length-4)
		let key = (string as NSString).substring(with: keyRange)
		var replacement = UserDefaults.standard.object(forKey: key)
		if replacement == nil {
			replacement = "<< missing value for \(key) >>"
		}
		newString = (newString as NSString).replacingCharacters(in: match.range, with: String(describing: replacement))
	}
	
	return newString
}
