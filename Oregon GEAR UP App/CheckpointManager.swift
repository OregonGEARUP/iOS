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
	
	private var blockInfo = [[String: String]]()
    
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
			self.blockInfo = blockInfo
			resumeCheckpointsInternal(completion: completion)
			return
		}
		
		
		// load the block info
		let url = URL(string: BaseURL + "blocks.json")!
		let task = URLSession.shared.dataTask(with: url) { (data, reponse, error) -> Void in
			
			var success = false
			if let data = data {
				
				if let jsonArray = try? JSONSerialization.jsonObject(with: data), let blockInfo = jsonArray as? [[String: String]] {
			
					self.blockInfo = blockInfo
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
		
		fetchCheckpoints(fromFile: filename, completion: completion)
	}
	
	public func loadBlock(atIndex index: Int, completion: @escaping (_ success: Bool) -> Void) {
		
		guard index < blockInfo.count else {
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
		
		fetchCheckpoints(fromFile: filename) { (success) in
			
			if success {
				self.persistState(forBlock: self.blockIndex, stage: self.stageIndex, checkpoint: self.checkpointIndex)	// TODO: this seems wrong??? or at least useless
			}
			
			completion(success)
		}
	}
	
	private func fetchCheckpoints(fromFile filename: String, completion: @escaping (_ success: Bool) -> Void) {
		
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
					
					// uppdate the blockIndex for the newly loaded block
					var blockIndex = -1
					var title = ""
					for (enumIndex, block) in self.blockInfo.enumerated() {
						
						guard let blockTitle = block["title"] else {
							continue
						}
						
						if title != blockTitle {
							blockIndex += 1
							title = blockTitle
						}
						
						if block["id"] == self.block.identifier {
							
							self.blockIndex = blockIndex
							self.blockInfo[enumIndex]["blockFileName"] = filename
							UserDefaults.standard.set(self.blockInfo, forKey: "blockInfo")
							
							break
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
		
		// enumerate blockInfo and count unique titles
		var count = 0
		var title = ""
		for block in blockInfo {
			
			guard let blockTitle = block["title"] else {
				continue
			}
			
			if title != blockTitle {
				count += 1
				title = blockTitle
			}
		}
		
		return count
	}
	
	public func blockInfo(forIndex index: Int) -> (title: String, filename: String, available: Bool) {
		
		var blockIndex = -1
		var title = ""
		for (enumIdx, block) in blockInfo.enumerated() {
			
			guard let blockTitle = block["title"], let blockFileName = block["blockFileName"] else {
				continue
			}
			
			if title != blockTitle {
				blockIndex += 1
				title = blockTitle
				
				if index == blockIndex {
					var filename = blockFileName
					if !filename.isEmpty {
						return (blockTitle, filename, !filename.isEmpty)
					}
					
					for block in blockInfo.suffix(from: enumIdx+1) {
						
						guard let blockTitle = block["title"], let blockFileName = block["blockFileName"] else {
							continue
						}
						
						if title != blockTitle {
							break
						}
						
						filename = blockFileName
						if !filename.isEmpty {
							break
						}
					}
					
					return (blockTitle, filename, !filename.isEmpty)
				}
			}
		}
		
		fatalError("blockInfo not found for index: \(index)")
	}
}
