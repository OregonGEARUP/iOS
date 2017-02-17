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
    case fieldDateEntry = "fielddate"
    case checkboxEntry = "checkbox"
}

class BaseInstance {
    let prompt: String
	let placeholder: String
	
	init(prompt: String, placeholder: String){
        self.prompt = prompt
		self.placeholder = placeholder
    }
}

class FieldInstance: BaseInstance{
}

class RadioInstance: BaseInstance{
}

class FieldDateInstance: BaseInstance{
}

class CheckboxInstance: BaseInstance{
}

struct Entry {
    var type: EntryType
    var instances = [BaseInstance]()
	
    // Make field entry struct that has two fields, prompt & placeholder (array of those)
    init?(type: EntryType, instances: [BaseInstance]){
        self.type = type
        if instances.isEmpty {return nil}
        self.instances = instances
    }
}

class Checkpoint {
    var title: String
    var description: String
    var moreInfo: String?
    
    var entry: Entry
    
    init(title: String, description: String, moreInfo: String?, type: EntryType, instances: [BaseInstance]){
        self.title = title
        self.description = description
        self.moreInfo = moreInfo
        self.entry = Entry(type: type, instances: instances)!
    }
}
