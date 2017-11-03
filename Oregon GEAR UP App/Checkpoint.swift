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
	case nextStage = "nextstage"
}

struct Instance {
	let identifier: String
    let prompt: String
	let placeholder: String
	
	var promptSubstituted: String { return stringWithSubstitutions(prompt).newString }
	var placeholderSubstituted: String { return stringWithSubstitutions(placeholder).newString }
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
	
	let criteria: [[String: String]]?
	let routeFileName: String?
	
	var entryTypeKey: String {
		return type.rawValue
	}
	
	var meetsCriteria: Bool {
		
		var meets = true
		if let criteria = criteria {
			
			// check to see that all criteria are met
			for crit in criteria {
				
				if let key = crit["key"], let expectedValue = crit["value"] {
					
					// empty keys are a match
					if key == "" {
						continue
					}
					
					// check that value for the key matches the expected value
					if let obj = UserDefaults.standard.object(forKey: key) {
						let value = String(describing: obj).lowercased()
						let expectedValue = expectedValue.lowercased()
						meets = meets && (value == expectedValue)
					} else {
						meets = false
					}
					
					if !meets {
						break
					}
				}
			}
		}
		
		// make sure we have a route destination
		if meets && routeFileName == nil {
			meets = false
		}
		
		return meets
	}
	
	public func isCompleted(forBlockIndex blockIndex: Int, stageIndex: Int, checkpointIndex: Int) -> Bool {
		
		if required == false {
			return true
		}
		
		let defaults = UserDefaults.standard
		
		switch type {
		case .infoEntry, .checkboxEntry, .routeEntry, .nextStage:
			return true
			
		case .radioEntry:
			var oneOn = false
			for (index, _) in instances.enumerated() {
				let key = CheckpointManager.shared.keyForBlockIndex(blockIndex, stageIndex: stageIndex, checkpointIndex: checkpointIndex, instanceIndex: index)
				oneOn = defaults.bool(forKey: key)
				if oneOn {
					break
				}
			}
			return oneOn
			
		case .fieldEntry, .dateOnlyEntry:
			var allFilled = true
			for (index, _) in instances.enumerated() {
				let key = CheckpointManager.shared.keyForBlockIndex(blockIndex, stageIndex: stageIndex, checkpointIndex: checkpointIndex, instanceIndex: index)
				if let str = defaults.string(forKey: key), str.isEmpty == false {
					allFilled = true
				} else {
					allFilled = false
					break
				}
			}
			return allFilled
			
		case .dateAndTextEntry:
			var allFilled = true
			for (index, _) in instances.enumerated() {
				let key = CheckpointManager.shared.keyForBlockIndex(blockIndex, stageIndex: stageIndex, checkpointIndex: checkpointIndex, instanceIndex: index)
				if let text = defaults.string(forKey: key+"_text"), let date = defaults.string(forKey: key+"_date"), text.isEmpty == false, date.isEmpty == false {
					allFilled = true
				} else {
					allFilled = false
					break
				}
			}
			return allFilled
		}
	}
	
	var titleSubstituted: String { return stringWithSubstitutions(title).newString }
	var descriptionSubstituted: String { return stringWithSubstitutions(description).newString }
	var moreInfoSubstituted: String? { return (moreInfo != nil ? stringWithSubstitutions(moreInfo!).newString : nil) }
}


private var re: NSRegularExpression {
	return try! NSRegularExpression(pattern: "##[^(##)]+##", options: [])
}

public func stringWithSubstitutions(_ string: String) -> (newString: String, good: Bool) {
	
	let matches = re.matches(in: string, options: [], range: NSMakeRange(0, string.count))
	
	var good = true
	var newString = string
	for match in matches.reversed() {
		let keyRange = NSMakeRange(match.range.location+2, match.range.length-4)
		let key = (string as NSString).substring(with: keyRange)
		var replacement = UserDefaults.standard.object(forKey: key)
		if replacement == nil {
			replacement = "<< missing value for \(key) >>"
			good = false
		}
		newString = (newString as NSString).replacingCharacters(in: match.range, with: String(describing: replacement!))
	}
	
	return (newString: newString, good: good)
}

