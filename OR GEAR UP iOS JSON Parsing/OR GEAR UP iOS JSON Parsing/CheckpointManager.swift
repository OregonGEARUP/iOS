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
       // self.checkpoints = loadCheckpoints()
        /*fetchJSON() { (success) in
            
            print("fetchJSON was successful: \(success)")
            
        }*/
    }
    
    func fetchJSON(completion: @escaping (_ success: Bool) -> Void) {
        let urlstr = NSString(format: "https://raw.githubusercontent.com/Sam-Makman/json/master/fields.json") as String
        let url = URL(string: urlstr)
        
        let session = URLSession.shared
        let task = session.dataTask(with: url!) { (data, reponse, error) -> Void in
            
            var success = false
            if let data = data {
                
                //print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
                
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] {
                        
                        // print out the array of dictionaries
                        //print(jsonArray)
                        
                        
                        // TODO: parse and store the data
                        //var checkpoints: [Checkpoint] = []
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
                                case .CheckboxEntry:
                                    guard let prompt = instance["prompt"], let placeholder = instance["placeholder"]
                                        else {break}
                                    let checkboxInstance = CheckboxInstance(prompt: prompt, placeholder: placeholder)
                                    cpInstances.append(checkboxInstance)
                                case .FieldDateEntry:
                                    guard let prompt = instance["prompt"], let placeholder = instance["placeholder"]
                                        else {break}
                                    let fielddateInstance = FieldDateInstance(prompt: prompt, placeholder: placeholder)
                                    cpInstances.append(fielddateInstance)
                                }
                                
                                
                            }
                            
                            let checkpoint = Checkpoint(title: title, description: description, moreInfo: moreInfo, type: type, instances: cpInstances)
                            self.checkpoints.append(checkpoint)
                        }
                        for checkpoint in CheckpointManager.sharedManager.checkpoints {
                            print(checkpoint.title)
                            print(checkpoint.description)
                            print(checkpoint.moreInfo)
                            print(checkpoint.entry.type)
                            for instance in checkpoint.entry.instances{
                                print(instance)
                            }
                        }
                        
                        success = true
                    }
                    
                } catch {
                    print("JSON error")
                }
                
                // call the completion block on the main thread
                DispatchQueue.main.async(execute: {
                    completion(success)
                })
            }
        }
        
        // run the task to fetch the JSON data
        task.resume()
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
                    case .CheckboxEntry:
                        guard let prompt = instance["prompt"], let placeholder = instance["placeholder"]
                            else {break}
                        let checkboxInstance = CheckboxInstance(prompt: prompt, placeholder: placeholder)
                        cpInstances.append(checkboxInstance)
                    case .FieldDateEntry:
                        guard let prompt = instance["prompt"], let placeholder = instance["placeholder"]
                            else {break}
                        let fielddateInstance = FieldDateInstance(prompt: prompt, placeholder: placeholder)
                        cpInstances.append(fielddateInstance)
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


