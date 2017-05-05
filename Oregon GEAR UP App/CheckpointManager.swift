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
	
	private var blockInfos = [[String: String]]()
    
	private var internalBlock: Block?
	
	public var block: Block {
		guard let block = self.internalBlock else {
			fatalError("no block")
		}
		return block
	}
	
	private var blockFilename: String?
	public var blockIndex = 0
	public var stageIndex = 0
	public var checkpointIndex = 0
	
    private init() {
    }
	
	private let BaseURL = "https://oregongoestocollege.org/mobileApp/json/"
	
	public func persistState(forBlock block: Int, stage: Int, checkpoint: Int) {
		
		guard let blockFilename = blockFilename else {
			fatalError("persistState called before first block file was loaded")
		}
		
		print("persistState: \(blockFilename)  b:\(block) s:\(stage) cp:\(checkpoint)")
		
		blockIndex = block
		stageIndex = stage
		checkpointIndex = checkpoint
		
		let defaults = UserDefaults.standard
		defaults.set(blockFilename, forKey: "currentBlockFilename")
		defaults.set(block, forKey: "currentBlockIndex")
		defaults.set(stage, forKey: "currentStageIndex")
		defaults.set(checkpoint, forKey: "currentCheckpointIndex")
	}
	
	public func keyForBlockIndex(_ blockIndex: Int, stageIndex: Int, checkpointIndex: Int, instanceIndex: Int) -> String {
		let stage = block.stages[stageIndex]
		let cp = stage.checkpoints[checkpointIndex]
		let instance = cp.instances[instanceIndex]
		return "\(block.identifier)_\(stage.identifier)_\(cp.identifier)_\(instance.identifier)"
	}
	
	public func resumeCheckpoints(completion: @escaping (_ success: Bool) -> Void) {
		
		if let blockInfo = UserDefaults.standard.array(forKey: "blockInfo") as? [[String: String]] {
			self.blockInfos = blockInfo
			resumeCheckpointsInternal(completion: completion)
			return
		}
		
		
//		// TEMPORARY in place of loading blocks info below
//		let b1 = ["ids": "b1", "title": "Explore your options.", "blockFileName": "block1.json"]
//		blockInfos.append(b1)
//		let b2 = ["ids": "b2", "title": "Be prepared.", "blockFileName": ""]
//		blockInfos.append(b2)
//		let b3 = ["ids": "b3citizen,b3undocumented,b3visa", "title": "Learn how to pay.", "blockFileName": ""]
//		blockInfos.append(b3)
//		let b4 = ["ids": "b4", "title": "Get Organized.", "blockFileName": ""]
//		blockInfos.append(b4)
//		let b5 = ["ids": "b5citizen,b5undocumented,b5visa", "title": "Get paid.", "blockFileName": ""]
//		blockInfos.append(b5)
//		let b6 = ["ids": "b6cc,b6cc,b6cc", "title": "Get set for college applications.", "blockFileName": ""]
//		blockInfos.append(b6)
//		let b7 = ["ids": "b7citizen,b7undocumented,b7visa", "title": "Follow up.", "blockFileName": ""]
//		blockInfos.append(b7)
//		let b8 = ["ids": "b8cc,b8noncc", "title": "Apply!", "blockFileName": ""]
//		blockInfos.append(b8)
//		let b9 = ["ids": "b9citizen,b9noncitizen", "title": "Look ahead.", "blockFileName": ""]
//		blockInfos.append(b9)
//		let b10 = ["ids": "b10", "title": "Make your choice.", "blockFileName": ""]
//		blockInfos.append(b10)
//		let b11 = ["ids": "b11", "title": "Tie up loose ends.", "blockFileName": ""]
//		blockInfos.append(b11)
//		let b12 = ["ids": "b12", "title": "Get ready to go.", "blockFileName": ""]
//		blockInfos.append(b12)
//		
//		resumeCheckpointsInternal(completion: completion)
		
		
		// load the block info
		let url = URL(string: BaseURL + "blocks.json")!
		let task = URLSession.shared.dataTask(with: url) { (data, reponse, error) -> Void in
			
			var success = false
			if let data = data {
				
				if let jsonArray = try? JSONSerialization.jsonObject(with: data), let blockInfos = jsonArray as? [[String: String]] {
			
					self.blockInfos = blockInfos
					success = true
				}
			}
			
			if success == false {
				
				completion(false)
				return
			}
			
			self.resumeCheckpointsInternal(completion: completion)
			return
		}
		
		task.resume()
	}
	
	private func resumeCheckpointsInternal(completion: @escaping (_ success: Bool) -> Void) {
		
		let defaults = UserDefaults.standard
		let filename = defaults.string(forKey: "currentBlockFilename") ?? "block1.json"
		
		if defaults.object(forKey: "currentBlockIndex") != nil {
			blockIndex = defaults.integer(forKey: "currentBlockIndex")
		} else {
			blockIndex = -1
		}
		
		if defaults.object(forKey: "currentStageIndex") != nil {
			stageIndex = defaults.integer(forKey: "currentStageIndex")
		} else {
			stageIndex = -1
		}
		
		if defaults.object(forKey: "currentCheckpointIndex") != nil {
			checkpointIndex = defaults.integer(forKey: "currentCheckpointIndex")
		} else {
			checkpointIndex = -1
		}
		
		fetchBlock(fromFile: filename, completion: completion)
	}
	
	public func loadBlock(atIndex index: Int, completion: @escaping (_ success: Bool) -> Void) {
		
		guard index < blockInfos.count else {
			fatalError("loadBlock: out of bounds")
		}
		
		let block = blockInfo(forIndex: index)
		
		guard block.available else {
			fatalError("loadBlock: unknown block file")
		}
		
		// see if the block is already loaded
		if block.filename == blockFilename {
			completion(true)
			return
		}
		
		loadNextBlock(fromFile: block.filename, completion: completion)
	}
	
	public func loadNextBlock(fromFile filename: String, completion: @escaping (_ success: Bool) -> Void) {
		
		stageIndex = -1
		checkpointIndex = -1
		
		fetchBlock(fromFile: filename) { (success) in
			
			if success {
				self.persistState(forBlock: self.blockIndex, stage: self.stageIndex, checkpoint: self.checkpointIndex)	// TODO: this seems wrong??? or at least useless
			}
			
			completion(success)
		}
	}
	
	private func fetchBlock(fromFile filename: String, completion: @escaping (_ success: Bool) -> Void) {
		
		URLCache.shared.removeAllCachedResponses()
		
		let url = URL(string: BaseURL + filename)!
        let task = URLSession.shared.dataTask(with: url) { (data, reponse, error) -> Void in
            
            var success = false
            if let data = data {
				
				do {
					if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
						
						self.internalBlock = self.parseBlock(from: jsonArray)
						self.blockFilename = filename
						success = true
					}
				} catch {
					print("JSON error")
				}
				
				// cache this JSON file data
				if success, let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first {
					let fileurl = URL(fileURLWithPath: dir).appendingPathComponent(filename)
					try? data.write(to: fileurl)
				}
				
				if success {
					
					// update the blockIndex for the newly loaded block
					for (index, blockInfo) in self.blockInfos.enumerated() {
						
						if let blockIds = blockInfo["ids"] {
							
							let ids = blockIds.characters.split{$0 == ","}.map(String.init)
							if ids.index(of: self.block.identifier) != nil {
								
								self.blockIndex = index
								self.blockInfos[index]["blockFileName"] = filename
								UserDefaults.standard.set(self.blockInfos, forKey: "blockInfo")
								
								break
							}
						}
					}
				}
				
                // call the completion block on the main thread
                DispatchQueue.main.async(execute: {
                    completion(success)
                })
			} else {
				
				// TODO: handle failure here by checking to see if we have the desired file cached
				
			}
        }
        
        // run the task to fetch the JSON data
        task.resume()
    }
	
	private func parseBlock(from jsonArray: [[String: Any]]) -> Block? {
		
		for jsonDict in jsonArray {
			
			guard let title = jsonDict["blocktitle"] as? String,
				let identifier = jsonDict["id"] as? String,
				let jsonArray = jsonDict["stages"] as? [[String: Any]]
			else {
				continue
			}
			
			let stages = parseStages(from: jsonArray)
			return Block(identifier: identifier, title: title, stages: stages)
		}
		
		return nil
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
			
			// optional route fields
			let criteria = jsonDict["criteria"] as? [[String: String]]		// for testing: ["b1_s3_cp2_checkbox1": "1"]
			let routeFileName = jsonDict["routeFileName"] as? String
			
			var cpInstances = [Instance]()
			for  instance in instances {
				
				guard let identifier = instance["id"],
					let prompt = instance["prompt"],
					let placeholder = instance["placeholder"]
				else {
					continue
				}
				
				cpInstances.append(Instance(identifier: identifier, prompt: prompt, placeholder: placeholder))
			}
			
			let checkpoint = Checkpoint(identifier: identifier, required: required, title: title, description: description, moreInfo: moreInfo, moreInfoURL: moreInfoURL, type: type, instances: cpInstances, criteria: criteria, routeFileName: routeFileName)
			checkpoints.append(checkpoint)
		}
		
		return checkpoints
	}
	
	
	public func countOfBlocks() -> Int {
		
		return blockInfos.count
	}
	
	public func blockInfo(forIndex index: Int) -> (title: String, filename: String, available: Bool) {
		
		let blockInfo = blockInfos[index]
		
		guard let title = blockInfo["title"], let filename = blockInfo["blockFileName"] else {
			fatalError("blockInfo missing elements")
		}
		
		return (title, filename, !filename.isEmpty)
	}
}
