//
//  CheckpointManager.swift
//  Oregon GEAR UP App
//
//  Created by Max MacEachern on 11/28/16.
//  Copyright © 2016 Oregon GEAR UP. All rights reserved.
//

import Foundation
  

class CheckpointManager {
    
    static let shared = CheckpointManager()
    
    var blocks = [Block]()
	
	// TEMPORARY bridge to a set of Checkpoints
	var checkpoints: [Checkpoint] {
		return blocks[0].stages[0].checkpoints
	}
    
    private init() {
    }
    
    public func fetchCheckpoints(completion: @escaping (_ success: Bool) -> Void) {
		
		URLCache.shared.removeAllCachedResponses()
		
//		let url = URL(string: "https://oregongoestocollege.org/mobileApp/SampleData.json")!
		let url = URL(string: "https://oregongoestocollege.org/mobileApp/ExploreYourOptions.json")!
        let task = URLSession.shared.dataTask(with: url) { (data, reponse, error) -> Void in
            
            var success = false
            if let data = data {
				
				do {
					if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
						
						self.blocks = self.parseBlocks(from: jsonArray)
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
	
	public func keyForBlockIndex(_ blockIndex: Int, stageIndex: Int, checkpointIndex: Int, instanceIndex: Int) -> String {
		let cp = blocks[blockIndex].stages[stageIndex].checkpoints[checkpointIndex]
		return "\(blocks[blockIndex].identifier)_\(blocks[blockIndex].stages[stageIndex].identifier)_\(cp.identifier)_\(cp.entryTypeKey)\(instanceIndex)"
	}
	
	private func parseBlocks(from jsonArray: [[String: Any]]) -> [Block] {
		
		var blocks = [Block]()
		for jsonDict in jsonArray {
			
			guard let title = jsonDict["blocktitle"] as? String,
				let identifier = jsonDict["id"] as? String,
				let jsonArray = jsonDict["stages"] as? [[String: Any]]
			else {
				continue
			}
			
			let stages = parseStages(from: jsonArray)
			let block = Block(identifier: identifier, title: title, stages: stages)
			blocks.append(block)
		}
		
		return blocks
	}
	
	private func parseStages(from jsonArray: [[String: Any]]) -> [Stage] {
		
		var stages = [Stage]()
		for jsonDict in jsonArray {
			
			guard let identifier = jsonDict["id"] as? String,
				let title = jsonDict["title"] as? String,
				let image = jsonDict["img"] as? String,
				let jsonArray = jsonDict["checkpoints"] as? [[String: Any]]
			else {
				continue
			}
			
			let checkpoints = parseCheckpoints(from: jsonArray)
			let stage = Stage(identifier: identifier, title: title, image: image, checkpoints: checkpoints)
			stages.append(stage)
		}
		
		return stages
	}
	
	private func parseCheckpoints(from jsonArray: [[String: Any]]) -> [Checkpoint] {
		
		var checkpoints = [Checkpoint]()
		for jsonDict in jsonArray {
			
			// required fields
			guard let identifier = jsonDict["id"] as? String,
				let requiredStr = jsonDict["requiredCP"] as? String,
				let title = jsonDict["title"] as? String,
				let description = jsonDict["description"] as? String,
				let typeStr = jsonDict["type"] as? String,
				let type = EntryType(rawValue: typeStr),
				let instances = jsonDict["instances"] as? [[String: String]]
			else {
				continue
			}
			
			let required = (requiredStr.lowercased() == "yes")
			
			// optional fields
			let moreInfo = jsonDict["urlText"] as? String
			var moreInfoURL: URL? = nil
			if let moreInfoURLStr = jsonDict["url"] as? String {
				moreInfoURL = URL(string: moreInfoURLStr)
			}
			
			var cpInstances = [Instance]()
			for  instance in instances {
				
				guard let prompt = instance["prompt"],
					let placeholder = instance["placeholder"]
				else {
					continue
				}
				
				cpInstances.append(Instance(prompt: prompt, placeholder: placeholder))
			}
			
			let checkpoint = Checkpoint(identifier: identifier, required: required, title: title, description: description, moreInfo: moreInfo, moreInfoURL: moreInfoURL, type: type, instances: cpInstances)
			checkpoints.append(checkpoint)
		}
		
		return checkpoints
	}
}
