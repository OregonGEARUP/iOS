//
//  EntryManager.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 11/22/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import Foundation


class EntryManager {
	
	static let shared = EntryManager()
	
	private var entries: [String: Any]
	
	private init() {
		
		// get persisted entries
		if let entries = UserDefaults.standard.object(forKey: "entries") as? [String: Any] {
			self.entries = entries
		} else if UserDefaults.standard.bool(forKey: "entry_conversion_done") == false {
			
			// NOTE: one-time conversion from v1 entrie storage in UserDefaults
			
			// find keys for the checkpoint entries
			let entryKeys = Set(UserDefaults.standard.dictionaryRepresentation().keys.filter { (key) -> Bool in
				guard let b = key.first, b == "b" else {
					return false
				}
				
				let key1 = key.dropFirst()
				guard let n = key1.first, n >= "1", n <= "9" else {
					return false
				}
				
				return true
			})
			
			// get the entries for the keys
			self.entries = UserDefaults.standard.dictionaryRepresentation().filter { (key, _) -> Bool in
				return entryKeys.contains(key)
			}
			//print(self.entries)

			// remove entries from UserDefaults
			Array(entryKeys).forEach { UserDefaults.standard.removeObject(forKey: $0) }
			
			// record that we have done the conversion
			UserDefaults.standard.set(true, forKey: "entry_conversion_done")
			
		} else {
			
			// starting from the beginning empty
			self.entries = [String: Any]()
		}
		
		
		// persist entries
		NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationWillResignActive, object: nil, queue: nil) { (note) in
			UserDefaults.standard.set(self.entries, forKey: "entries")
		}
	}
	
	
	// MARK: - Set entry
	
	public func set(_ value: Any?, forKey key: String) {
		
		entries[key] = value
	}
	
	public func clearForKey(_ key: String) {
		
		entries.removeValue(forKey: key)
	}
	
	
	// MARK: - Get entry
	
	public func textForKey(_ key: String) -> String? {
		
		guard let text = entries[key] as? String else {
			return nil
		}
		return text
	}
	
	public func boolForKey(_ key: String) -> Bool {
		
		guard let bool = entries[key] as? Bool else {
			return false
		}
		return bool
	}
	
	public func descriptionForKey(_ key: String) -> String? {
		
		guard let value = entries[key] else {
			return nil
		}
		return String(describing: value)
	}
}
