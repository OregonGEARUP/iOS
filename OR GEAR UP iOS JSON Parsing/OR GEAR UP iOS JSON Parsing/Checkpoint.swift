//
//  Checkpoint.swift
//  OR GEAR UP iOS JSON Parsing
//
//  Created by Max MacEachern on 9/26/16.
//  Copyright © 2016 Max MacEachern. All rights reserved.
//

import Foundation

enum EntryType: String {
    case FieldEntry = "field"
    case RadioEntry = "radio"
    
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
