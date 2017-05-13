//
//  Residency.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 5/13/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import Foundation


struct Residency {
	
	var residencyStart: Date?
	var residencyEnd: Date?
	var parentResidencyStart: Date?
	var parentResidencyEnd: Date?
	
	var registerToVote: Date?
	var parentsRegisterToVote: Date?

	var militaryServiceStart: Date?
	var militaryServiceEnd: Date?
	var parentMilitaryServiceStart: Date?
	var parentMilitaryServiceEnd: Date?
	
	var fileOregonTaxesYear1: Date?
	var fileOregonTaxesYear2: Date?
	var parentsFileOregonTaxesYear1: Date?
	var parentsFileOregonTaxesYear2: Date?
	
	var nameEmployer1: String?
	var cityEmployer1: String?
	var startEmployer1: Date?
	var endEmployer1: Date?
	var nameEmployer2: String?
	var cityEmployer2: String?
	var startEmployer2: Date?
	var endEmployer2: Date?
	
	var parentNameEmployer1: String?
	var parentCityEmployer1: String?
	var parentStartEmployer1: Date?
	var parentEndEmployer1: Date?
	var parentNameEmployer2: String?
	var parentCityEmployer2: String?
	var parentStartEmployer2: Date?
	var parentEndEmployer2: Date?
	
	public init() {
		
	}
	
	public init?(fromDictionary dictionary: [String: Any]) {
		
		if let residencyStart = dictionary["residencyStart"] as? String {
			self.residencyStart = Date(longDescription: residencyStart)
		}
		if let residencyEnd = dictionary["residencyEnd"] as? String {
			self.residencyEnd = Date(longDescription: residencyEnd)
		}
		if let parentResidencyStart = dictionary["parentResidencyStart"] as? String {
			self.parentResidencyStart = Date(longDescription: parentResidencyStart)
		}
		if let parentResidencyEnd = dictionary["parentResidencyEnd"] as? String {
			self.parentResidencyEnd = Date(longDescription: parentResidencyEnd)
		}
		
		if let registerToVote = dictionary["registerToVote"] as? String {
			self.registerToVote = Date(longDescription: registerToVote)
		}
		if let parentsRegisterToVote = dictionary["parentsRegisterToVote"] as? String {
			self.parentsRegisterToVote = Date(longDescription: parentsRegisterToVote)
		}
		
		if let militaryServiceStart = dictionary["militaryServiceStart"] as? String {
			self.militaryServiceStart = Date(longDescription: militaryServiceStart)
		}
		if let militaryServiceEnd = dictionary["militaryServiceEnd"] as? String {
			self.militaryServiceEnd = Date(longDescription: militaryServiceEnd)
		}
		if let parentMilitaryServiceStart = dictionary["parentMilitaryServiceStart"] as? String {
			self.parentMilitaryServiceStart = Date(longDescription: parentMilitaryServiceStart)
		}
		if let parentMilitaryServiceEnd = dictionary["parentMilitaryServiceEnd"] as? String {
			self.parentMilitaryServiceEnd = Date(longDescription: parentMilitaryServiceEnd)
		}
		
		if let fileOregonTaxesYear1 = dictionary["fileOregonTaxesYear1"] as? String {
			self.fileOregonTaxesYear1 = Date(longDescription: fileOregonTaxesYear1)
		}
		if let fileOregonTaxesYear2 = dictionary["fileOregonTaxesYear2"] as? String {
			self.fileOregonTaxesYear2 = Date(longDescription: fileOregonTaxesYear2)
		}
		if let parentsFileOregonTaxesYear1 = dictionary["parentsFileOregonTaxesYear1"] as? String {
			self.parentsFileOregonTaxesYear1 = Date(longDescription: parentsFileOregonTaxesYear1)
		}
		if let parentsFileOregonTaxesYear2 = dictionary["parentsFileOregonTaxesYear2"] as? String {
			self.parentsFileOregonTaxesYear2 = Date(longDescription: parentsFileOregonTaxesYear2)
		}
		
		if let nameEmployer1 = dictionary["nameEmployer1"] as? String {
			self.nameEmployer1 = nameEmployer1
		}
		if let cityEmployer1 = dictionary["cityEmployer1"] as? String {
			self.cityEmployer1 = cityEmployer1
		}
		if let startEmployer1 = dictionary["startEmployer1"] as? String {
			self.startEmployer1 = Date(longDescription: startEmployer1)
		}
		if let endEmployer1 = dictionary["endEmployer1"] as? String {
			self.endEmployer1 = Date(longDescription: endEmployer1)
		}
		
		if let nameEmployer2 = dictionary["nameEmployer2"] as? String {
			self.nameEmployer2 = nameEmployer2
		}
		if let cityEmployer2 = dictionary["cityEmployer2"] as? String {
			self.cityEmployer2 = cityEmployer2
		}
		if let startEmployer2 = dictionary["startEmployer2"] as? String {
			self.startEmployer2 = Date(longDescription: startEmployer2)
		}
		if let endEmployer2 = dictionary["endEmployer2"] as? String {
			self.endEmployer2 = Date(longDescription: endEmployer2)
		}
		
		if let parentNameEmployer1 = dictionary["parentNameEmployer1"] as? String {
			self.parentNameEmployer1 = parentNameEmployer1
		}
		if let parentCityEmployer1 = dictionary["parentCityEmployer1"] as? String {
			self.parentCityEmployer1 = parentCityEmployer1
		}
		if let parentStartEmployer1 = dictionary["parentStartEmployer1"] as? String {
			self.parentStartEmployer1 = Date(longDescription: parentStartEmployer1)
		}
		if let parentEndEmployer1 = dictionary["parentEndEmployer1"] as? String {
			self.parentEndEmployer1 = Date(longDescription: parentEndEmployer1)
		}
		
		if let parentNameEmployer2 = dictionary["parentNameEmployer2"] as? String {
			self.parentNameEmployer2 = parentNameEmployer2
		}
		if let parentCityEmployer2 = dictionary["parentCityEmployer2"] as? String {
			self.parentCityEmployer2 = parentCityEmployer2
		}
		if let parentStartEmployer2 = dictionary["parentStartEmployer2"] as? String {
			self.parentStartEmployer2 = Date(longDescription: parentStartEmployer2)
		}
		if let parentEndEmployer2 = dictionary["parentEndEmployer2"] as? String {
			self.parentEndEmployer2 = Date(longDescription: parentEndEmployer2)
		}
	}
	
	public func serializeToDictionary() -> [String: Any] {
		
		var dictionary = [String: Any]()
		
		if let residencyStart = residencyStart?.longDescription {
			dictionary["residencyStart"] = residencyStart
		}
		if let residencyEnd = residencyEnd?.longDescription {
			dictionary["residencyEnd"] = residencyEnd
		}
		if let parentResidencyStart = parentResidencyStart?.longDescription {
			dictionary["parentResidencyStart"] = parentResidencyStart
		}
		if let parentResidencyEnd = parentResidencyEnd?.longDescription {
			dictionary["parentResidencyEnd"] = parentResidencyEnd
		}
		
		if let registerToVote = registerToVote?.longDescription {
			dictionary["registerToVote"] = registerToVote
		}
		if let parentsRegisterToVote = parentsRegisterToVote?.longDescription {
			dictionary["parentsRegisterToVote"] = parentsRegisterToVote
		}
		
		if let militaryServiceStart = militaryServiceStart?.longDescription {
			dictionary["militaryServiceStart"] = militaryServiceStart
		}
		if let militaryServiceEnd = militaryServiceEnd?.longDescription {
			dictionary["militaryServiceEnd"] = militaryServiceEnd
		}
		if let parentMilitaryServiceStart = parentMilitaryServiceStart?.longDescription {
			dictionary["parentMilitaryServiceStart"] = parentMilitaryServiceStart
		}
		if let parentMilitaryServiceEnd = parentMilitaryServiceEnd?.longDescription {
			dictionary["parentMilitaryServiceEnd"] = parentMilitaryServiceEnd
		}
		
		if let fileOregonTaxesYear1 = fileOregonTaxesYear1?.longDescription {
			dictionary["fileOregonTaxesYear1"] = fileOregonTaxesYear1
		}
		if let fileOregonTaxesYear2 = fileOregonTaxesYear2?.longDescription {
			dictionary["fileOregonTaxesYear2"] = fileOregonTaxesYear2
		}
		if let parentsFileOregonTaxesYear1 = parentsFileOregonTaxesYear1?.longDescription {
			dictionary["parentsFileOregonTaxesYear1"] = parentsFileOregonTaxesYear1
		}
		if let parentsFileOregonTaxesYear2 = parentsFileOregonTaxesYear2?.longDescription {
			dictionary["parentsFileOregonTaxesYear2"] = parentsFileOregonTaxesYear2
		}
		
		if let nameEmployer1 = nameEmployer1 {
			dictionary["nameEmployer1"] = nameEmployer1
		}
		if let cityEmployer1 = cityEmployer1 {
			dictionary["cityEmployer1"] = cityEmployer1
		}
		if let startEmployer1 = startEmployer1?.longDescription {
			dictionary["startEmployer1"] = startEmployer1
		}
		if let endEmployer1 = endEmployer1?.longDescription {
			dictionary["endEmployer1"] = endEmployer1
		}
		
		if let nameEmployer2 = nameEmployer2 {
			dictionary["nameEmployer2"] = nameEmployer2
		}
		if let cityEmployer2 = cityEmployer2 {
			dictionary["cityEmployer2"] = cityEmployer2
		}
		if let startEmployer2 = startEmployer2?.longDescription {
			dictionary["startEmployer2"] = startEmployer2
		}
		if let endEmployer2 = endEmployer2?.longDescription {
			dictionary["endEmployer2"] = endEmployer2
		}
		
		if let parentNameEmployer1 = parentNameEmployer1 {
			dictionary["parentNameEmployer1"] = parentNameEmployer1
		}
		if let parentCityEmployer1 = parentCityEmployer1 {
			dictionary["parentCityEmployer1"] = parentCityEmployer1
		}
		if let parentStartEmployer1 = parentStartEmployer1?.longDescription {
			dictionary["parentStartEmployer1"] = parentStartEmployer1
		}
		if let parentEndEmployer1 = parentEndEmployer1?.longDescription {
			dictionary["parentEndEmployer1"] = parentEndEmployer1
		}

		if let parentNameEmployer2 = parentNameEmployer2 {
			dictionary["parentNameEmployer2"] = parentNameEmployer2
		}
		if let parentCityEmployer2 = parentCityEmployer2 {
			dictionary["parentCityEmployer2"] = parentCityEmployer2
		}
		if let parentStartEmployer2 = parentStartEmployer2?.longDescription {
			dictionary["parentStartEmployer2"] = parentStartEmployer2
		}
		if let parentEndEmployer2 = parentEndEmployer2?.longDescription {
			dictionary["parentEndEmployer2"] = parentEndEmployer2
		}

		return dictionary
	}
}
