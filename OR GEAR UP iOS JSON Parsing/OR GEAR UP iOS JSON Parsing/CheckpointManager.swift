//
//  CheckpointManager.swift
//  OR GEAR UP iOS JSON Parsing
//
//  Created by Max MacEachern on 9/26/16.
//  Copyright © 2016 Max MacEachern. All rights reserved.
//

import Foundation


class CheckpointManager {
    
    static let sharedManager = CheckpointManager()      // this makes this class a "Singleton"
    
    var checkpoints: [Checkpoint] = []
    
    
    private init() {
        self.checkpoints = loadCheckpoints()
    }
    
    
    func loadCheckpoints() -> [Checkpoint] {
        
        let url = Bundle.main.url(forResource: "checkpoints", withExtension: "json")
        let data = NSData(contentsOf: url!)
        
        var checkpoints: [Checkpoint] = []
        do {
            let jsonArray = try JSONSerialization.jsonObject(with: data! as Data) as! [[String : Any]]
            for json in jsonArray{
                guard let title = json["title"] as? String, let description = json["description"] as? String
                    else {continue}
                let moreInfo = json["moreInfo"] as? String
                let cpEntry = json["entry"] as? [String: AnyObject]
                guard let typeStr = cpEntry?["type"] as? String
                    else {continue}
                
                // TODO: deal with optional
                let type = EntryType(rawValue: typeStr)!
                
                
                
                let instances = cpEntry?["instances"] as? [[String: String]]
                var cpInstances = [BaseInstance]()
                for  instance in instances!{
                    // TODO: Deal with '!' in code. 
                    // Cases for different types
                    
                    switch type {
                    case .FieldEntry:
                        guard let prompt = instance["prompt"], let placeholder = instance["placeholder"]
                            else {break}
                        let fieldInstance = FieldInstance(prompt: prompt, placeholder: placeholder)
                        cpInstances.append(fieldInstance)
                    case .RadioEntry:
                        guard let prompt = instance["prompt"], let placeholder = instance["placeholder"]
                            else {break}
                        let radioInstance = RadioInstance(prompt: prompt, placeholder: placeholder)
                        cpInstances.append(radioInstance)
                    }
                    
                    
                }
                
                let checkpoint = Checkpoint(title: title, description: description, moreInfo: moreInfo, type: type, instances: cpInstances)
                checkpoints.append(checkpoint)
            }
            for checkpoint in checkpoints {
                print(checkpoint.title)
                print(checkpoint.description)
                print(checkpoint.moreInfo)
                print(checkpoint.entry.type)
                for instance in checkpoint.entry.instances{
                    print(instance)
                }
            }
        }
        catch {
            print("error getting JSON data")
        }
        return checkpoints
    }
}


