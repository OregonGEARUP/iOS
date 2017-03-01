//
//  Checkpoint.swift
//  Oregon GEAR UP App
//
//  Created by Max MacEachern on 11/28/16.
//  Copyright © 2016 Oregon GEAR UP. All rights reserved.
//


enum EntryType: String {
    case fieldEntry = "field"
    case radioEntry = "radio"
    case fieldDateEntry = "date"
    case checkboxEntry = "checkbox"
}

struct Instance {
    let prompt: String
	let placeholder: String
}

struct Checkpoint {
    let title: String
    let description: String
    let moreInfo: String?
    
	let type: EntryType
	let instances: [Instance]
}
