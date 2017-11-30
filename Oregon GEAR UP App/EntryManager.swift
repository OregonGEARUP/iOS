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
	private let mode11 = false
	
	private init() {
		
		// get persisted entries
		if let entries = UserDefaults.standard.object(forKey: "entries") as? [String: Any] {
			self.entries = entries
		} else {
			self.entries = [String: Any]()
		}
		
		// persist entries
		NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationWillResignActive, object: nil, queue: nil) { (note) in
			UserDefaults.standard.set(self.entries, forKey: "entries")
		}
	}
	
	
	// MARK: - Set entry
	
	public func set(_ value: Any?, forKey key: String) {
		
		if mode11 {
			UserDefaults.standard.set(value, forKey: key)
			return
		}
		
		
		entries[key] = value
		
		// backward compatibility
		UserDefaults.standard.removeObject(forKey: key)
	}
	
	public func clearForKey(_ key: String) {
		
		if mode11 {
			UserDefaults.standard.removeObject(forKey: key)
			return
		}
		
		
		entries.removeValue(forKey: key)
		
		// backward compatibility
		UserDefaults.standard.removeObject(forKey: key)
	}
	
	
	// MARK: - Get entry
	
	public func textForKey(_ key: String) -> String? {
		
		if mode11 {
			return UserDefaults.standard.string(forKey: key)
		}
		
		
		guard let text = entries[key] as? String else {
			
			// backward compatibility
			if let udText = UserDefaults.standard.string(forKey: key) {
				UserDefaults.standard.removeObject(forKey: key)
				entries[key] = udText
				return udText
			}
			
			return nil
		}
		return text
	}
	
	public func boolForKey(_ key: String) -> Bool {
		
		if mode11 {
			return UserDefaults.standard.bool(forKey: key)
		}
		
		
		guard let bool = entries[key] as? Bool else {
			
			// backward compatibility
			if UserDefaults.standard.object(forKey: key) != nil {
				let udBool = UserDefaults.standard.bool(forKey: key)
				UserDefaults.standard.removeObject(forKey: key)
				entries[key] = udBool
				return udBool
			}
			
			return false
		}
		return bool
	}
	
	public func descriptionForKey(_ key: String) -> String? {
		
		if mode11 {
			if let obj = UserDefaults.standard.object(forKey: key) {
				return String(describing: obj)
			}
			return nil
		}
		
		
		guard let value = entries[key] else {
			return nil
		}
		return String(describing: value)
	}
}
