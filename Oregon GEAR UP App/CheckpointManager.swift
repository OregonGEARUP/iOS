//
//  CheckpointManager.swift
//  Oregon GEAR UP App
//
//  Created by Max MacEachern on 11/28/16.
//  Copyright © 2016 Oregon GEAR UP. All rights reserved.
//

import Foundation
  

class CheckpointManager {
    
    static let sharedManager = CheckpointManager()      // this makes this class a "Singleton"
    
    var checkpoints: [Checkpoint] = []
    
    private init() {
    }
    
    func fetchJSON(completion: @escaping (_ success: Bool) -> Void) {
        let urlstr = NSString(format: "https://raw.githubusercontent.com/Sam-Makman/json/master/fields.json") as String
        let url = URL(string: urlstr)
        
        let session = URLSession.shared
        let task = session.dataTask(with: url!) { (data, reponse, error) -> Void in
            
            var success = false
            if let data = data {
				
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] {
                        
                        for json in jsonArray {
							
							// required fields
							guard let title = json["title"] as? String,
								  let description = json["description"] as? String,
								  let cpEntry = json["entry"] as? [String: AnyObject],			// TODO: this level is going away in the new JSON
								  let typeStr = cpEntry["type"] as? String,
								  let type = EntryType(rawValue: typeStr),
								  let instances = cpEntry["instances"] as? [[String: String]]
							else {
								break
							}
							
							// optional fields
							let moreInfo = json["moreInfo"] as? String
							
							
                            var cpInstances = [Instance]()
                            for  instance in instances {
								
								guard let prompt = instance["prompt"],
									  let placeholder = instance["placeholder"]
								else {
									continue
								}
								
                                cpInstances.append(Instance(prompt: prompt, placeholder: placeholder))
                            }
                            
                            let checkpoint = Checkpoint(title: title, description: description, moreInfo: moreInfo, type: type, instances: cpInstances)
                            self.checkpoints.append(checkpoint)
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
}
