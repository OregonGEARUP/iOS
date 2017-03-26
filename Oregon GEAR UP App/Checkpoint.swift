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
    let prompt: String
	let placeholder: String
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
}
