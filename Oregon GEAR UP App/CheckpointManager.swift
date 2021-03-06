//
//  CheckpointManager.swift
//  Oregon GEAR UP App
//
//  Created by Max MacEachern on 11/28/16.
//  Copyright © 2016 Oregon GEAR UP. All rights reserved.
//

import Foundation


struct BlockInfo {
	let ids: String
	let title: String
	var blockFileName: String?
	var stageCount: Int?
	var stagesComplete: Int?
	
	var available: Bool {
		return blockFileName != nil
	}
	
	var done: Bool {
		if let complete = stagesComplete, let count = stageCount {
			return complete == count
		}
		return false
	}
	
	public init?(fromDictionary dictionary: [String: Any]) {
		
		if let ids = dictionary["ids"] as? String,
			let title = dictionary["title"] as? String {
			self.ids = ids
			self.title = title
		} else {
			return nil
		}
		
		self.blockFileName = dictionary["blockFileName"] as? String
		if self.blockFileName == "" {
			self.blockFileName = nil
		}
		
		self.stageCount = dictionary["stageCount"] as? Int
		self.stagesComplete = dictionary["stagesComplete"] as? Int
	}
	
	public func serializeToDictionary() -> [String: Any] {
		
		var dictionary = [String: Any]()
		
		dictionary["ids"] = ids
		dictionary["title"] = title
		
		if let blockFileName = blockFileName {
			dictionary["blockFileName"] = blockFileName
		}
		if let stageCount = stageCount {
			dictionary["stageCount"] = stageCount
		}
		if let stagesComplete = stagesComplete {
			dictionary["stagesComplete"] = stagesComplete
		}
		
		return dictionary
	}
}


class CheckpointManager {
    
    static let shared = CheckpointManager()
	
	private var blockInfos = [BlockInfo]()
    
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
	
	private var visited: Set<String>!
	
    private init() {
		
		if let visitedArray = UserDefaults.standard.array(forKey: "visited") as? [String] {
			visited = Set(visitedArray)
		} else {
			visited = Set<String>()
		}
		
		NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationWillResignActive, object: nil, queue: nil) { (note) in
			
			let visitedArray = Array(self.visited)
			//print("visitedArray: \(visitedArray)")
			UserDefaults.standard.set(visitedArray, forKey: "visited")
			
			self.persistBlockCompletionInfo()
		}
	}
	
	private let BaseURL = "https://oregongoestocollege.org/mobileApp/json/"
	
	public func resumeCheckpoints(completion: @escaping (_ success: Bool) -> Void) {
		
		if let blockInfo = UserDefaults.standard.array(forKey: "blockInfo") as? [[String: Any]] {
			self.blockInfos = blockInfo.map({ BlockInfo(fromDictionary: $0) }).compactMap({ $0 })
			resumeCheckpointsInternal(completion: completion)
			return
		}
		
		
		// load the block info
		let url = URL(string: BaseURL + "blocks.json")!
		let task = URLSession.shared.dataTask(with: url) { (data, reponse, error) -> Void in
			
			var success = false
			if let data = data {
				
				if let jsonArray = try? JSONSerialization.jsonObject(with: data), let blockInfo = jsonArray as? [[String: Any]] {
					
					self.blockInfos = blockInfo.map({ BlockInfo(fromDictionary: $0) }).compactMap({ $0 })
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
		
		var filename = defaults.string(forKey: "currentBlockFilename")
		
		// handle intial startup case with first block
		if filename == nil && blockInfos.count > 0 {
			filename = blockInfos[0].blockFileName
			blockIndex = -1
			stageIndex = -1
			checkpointIndex = -1
		}
		
		if let filename = filename {
			fetchBlock(fromFile: filename, completion: completion)
		} else {
			fatalError("no block filename in resumeCheckpointsInternal")
		}
	}
	
	public func loadBlock(atIndex index: Int, completion: @escaping (_ success: Bool) -> Void) {
		
		guard index < blockInfos.count else {
			fatalError("loadBlock: out of bounds")
		}
		
		let block = blockInfo(forIndex: index)
		
		guard let filename = block.blockFileName, block.available else {
			fatalError("loadBlock: unknown block file")
		}
		
		// see if the block is already loaded
		if filename == blockFilename {
			blockIndex = index
			completion(true)
			return
		}
		
		loadNextBlock(fromFile: filename, completion: completion)
	}
	
	public func loadNextBlock(fromFile filename: String, completion: @escaping (_ success: Bool) -> Void) {
		
		// persist block status for current block before loading next on
		persistBlockCompletionInfo()
		
		
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
						
						let ids = blockInfo.ids.split{$0 == ","}.map(String.init)
						if ids.index(of: self.block.identifier) != nil {
							
							self.blockIndex = index
							
							let status = self.blockStagesStatus()
							self.blockInfos[index].stagesComplete = status.completed
							self.blockInfos[index].stageCount = status.total
							self.blockInfos[index].blockFileName = filename
							
							let blockInfoArray = self.blockInfos.map { $0.serializeToDictionary() }
							UserDefaults.standard.set(blockInfoArray, forKey: "blockInfo")
							
							break
						}
					}
				}
				
                // call completion on the main thread
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
		let stageCount = jsonArray.count
		for (index, jsonDict) in jsonArray.enumerated() {
			
			guard let identifier = jsonDict["id"] as? String,
				let title = jsonDict["title"] as? String,
				let image = jsonDict["img"] as? String,
				let jsonArray = jsonDict["checkpoints"] as? [[String: Any]]
			else {
				continue
			}
			
			var checkpoints = parseCheckpoints(from: jsonArray)
			
			// add a next stage cp at the end of each stage (except the last one)
			if index < stageCount - 1 {
				let nextStageCP = Checkpoint(identifier: "ns", required: false, title: "", description: "", moreInfo: nil, moreInfoURL: nil, type: .nextStage, instances: [], criteria: [], routeFileName: nil)
				checkpoints.append(nextStageCP)
			}
			
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
				moreInfoURL = URL(string: moreInfoURLStr.trimmingCharacters(in: CharacterSet.whitespaces))
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
	
	
	// MARK: - block info
	
	public func countOfBlocks() -> Int {
		
		return blockInfos.count
	}
	
	public func blockInfo(forIndex index: Int) -> BlockInfo {
		
		return blockInfos[index]
	}
	
	
	// MARK: - completed
	
	public func persistBlockCompletionInfo() {
		
		guard blockIndex >= 0, let filename = blockFilename else {
			return
		}
		
		let status = self.blockStagesStatus()
		blockInfos[blockIndex].stagesComplete = status.completed
		blockInfos[blockIndex].stageCount = status.total
		blockInfos[blockIndex].blockFileName = filename
		
		let blockInfoArray = blockInfos.map { $0.serializeToDictionary() }
		UserDefaults.standard.set(blockInfoArray, forKey: "blockInfo")

	}
	
	public func blockCompleted() -> Bool {
		
		var completed = true
		for (stageIndex, _) in block.stages.enumerated() {
			completed = completed && stageCompleted(atIndex: stageIndex)
		}
		
		return completed
	}
	
	public func blockStagesStatus() -> (completed: Int, total: Int) {
		
		var completed = 0
		var total = 0
		for (stageIndex, _) in block.stages.enumerated() {
			completed += stageCompleted(atIndex: stageIndex) ? 1 : 0
			total += 1
		}
		
		return (completed, total)
	}
	
	public func stageCompleted(atIndex stageIndex: Int) -> Bool {
		
		var completed = true
		for (cpIndex, _) in block.stages[stageIndex].checkpoints.enumerated() {
			completed = completed && checkpointCompleted(atIndex: cpIndex, stageIndex: stageIndex)
			
			// check for completed route cp at the end of the stage, as soon as we find one visited
			// route cp then we are good for the stage (this assumes that route cps are alwaya at the end of a stage)
			if completed && block.stages[stageIndex].checkpoints[cpIndex].type == .routeEntry {
				break
			}
		}
		
		return completed
	}
	
	public func checkpointCompleted(atIndex cpIndex: Int, stageIndex: Int) -> Bool {
		
		let completed = hasVisited(block: 0, stage: stageIndex, checkpoint: cpIndex)
		if completed == false {
			return false
		}
		
		// check to see if checkpoint is completed
		let cp = block.stages[stageIndex].checkpoints[cpIndex]
		return cp.isCompleted(forBlockIndex: 0, stageIndex:stageIndex, checkpointIndex: cpIndex)
	}
	
	public func persistState(forBlock block: Int, stage: Int, checkpoint: Int) {
		
		guard let blockFilename = blockFilename else {
			print("persistState called before first block file was loaded")
			return
		}
		
		addTrace("persistState: \(blockFilename)  b:\(block) s:\(stage) cp:\(checkpoint)")
		
		blockIndex = block
		stageIndex = stage
		checkpointIndex = checkpoint
		
		let defaults = UserDefaults.standard
		defaults.set(blockFilename, forKey: "currentBlockFilename")
		defaults.set(block, forKey: "currentBlockIndex")
		defaults.set(stage, forKey: "currentStageIndex")
		defaults.set(checkpoint, forKey: "currentCheckpointIndex")
	}
	
	public func markVisited(forBlock block: Int, stage: Int, checkpoint: Int) {
		
		visited.insert(keyForBlockIndex(block, stageIndex: stage, checkpointIndex: checkpoint))
	}
	
	public func hasVisited(block: Int, stage: Int, checkpoint: Int) -> Bool {
		
		return visited.contains(keyForBlockIndex(block, stageIndex: stage, checkpointIndex: checkpoint))
	}

	public func keyForBlockIndex(_ blockIndex: Int, stageIndex: Int, checkpointIndex: Int, instanceIndex: Int) -> String {
		let stage = block.stages[stageIndex]
		let cp = stage.checkpoints[checkpointIndex]
		let instance = cp.instances[instanceIndex]
		return "\(block.identifier)_\(stage.identifier)_\(cp.identifier)_\(instance.identifier)"
	}
	
	public func keyForBlockIndex(_ blockIndex: Int, stageIndex: Int, checkpointIndex: Int) -> String {
		let stage = block.stages[stageIndex]
		let cp = stage.checkpoints[checkpointIndex]
		return "\(block.identifier)_\(stage.identifier)_\(cp.identifier)"
	}

	
	// MARK: - traces
	
	private var traces = [String]()
	
	public func addTrace(_ trace: String) {
		traces.append("\(Date()): \(trace)")
		
		//print(traces.last!)
	}
	
	public func allTraces() -> String {
		
		return traces.joined(separator: "\n")
	}
}
