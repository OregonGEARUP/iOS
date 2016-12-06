//
//  checkpoint.swift
//  Oregon GEAR UP App
//
//  Created by Max MacEachern on 11/28/16.
//  Copyright © 2016 Oregon GEAR UP. All rights reserved.
//

import Foundation

enum EntryType: String {
    case FieldEntry = "field"
    case RadioEntry = "radio"
    case FieldDateEntry = "fielddate"
    case CheckboxEntry = "checkbox"
    
}

class BaseInstance{
    let prompt: String
    init(prompt: String){
        self.prompt = prompt
    }
}

class FieldInstance: BaseInstance{
    let placeholder: String
    init(prompt: String, placeholder: String){
        self.placeholder = placeholder
        super.init(prompt: prompt)
    }
}

class RadioInstance: BaseInstance{
    let placeholder: String
    init(prompt: String, placeholder: String){
        self.placeholder = placeholder
        super.init(prompt: prompt)
    }
}

class FieldDateInstance: BaseInstance{
    let placeholder: String
    init(prompt: String, placeholder: String){
        self.placeholder = placeholder
        super.init(prompt: prompt)
    }
}

class CheckboxInstance: BaseInstance{
    let placeholder: String
    init(prompt: String, placeholder: String){
        self.placeholder = placeholder
        super.init(prompt: prompt)
    }
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
