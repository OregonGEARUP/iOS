//
//  MyPlanTableViewCells.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 5/11/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell {
	
	@IBOutlet var textField: UITextField!
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		selectionStyle = .none
    }
}


enum DateFieldType {
	case longDate
	case monthYear
	case year
}

class DateFieldCell: UITableViewCell {
	
	
	@IBOutlet var dateField: UIButton!
	
	public var type: DateFieldType = .longDate
	public var date = Date()
	public var placeholderText: String?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		selectionStyle = .none
		
		placeholderText = "tap to select date"
		
		dateField.layer.backgroundColor = UIColor.white.cgColor
		dateField.layer.borderColor = UIColor(white: 0.8, alpha: 1.0).cgColor
		dateField.layer.borderWidth = 0.5
		dateField.layer.cornerRadius = 5.0
		
		setDate(nil)
	}
	
	public func setDate(_ date: Date?, type: DateFieldType? = nil) {
		
		if let type = type {
			self.type = type
		}
		
		if let date = date {
			self.date = date
			
			switch self.type {
			case .longDate:		dateField.setTitle(date.longDescription, for: .normal)
			case .monthYear:	dateField.setTitle(date.monthYearDescription, for: .normal)
			case .year:			dateField.setTitle(date.yearDescription, for: .normal)
			}
			dateField.setTitleColor(.darkText, for: .normal)
		} else {
			self.date = Date()
			
			dateField.setTitle(placeholderText, for: .normal)
			dateField.setTitleColor(UIColor(white: 0.8, alpha: 1.0), for: .normal)
		}
	}
}


class ButtonCell: UITableViewCell {
	
	@IBOutlet var button: UIButton!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		selectionStyle = .none
	}
}


class CheckboxCell: UITableViewCell {
	
	@IBOutlet private var cbImage: UIImageView!
	@IBOutlet private var label: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		selectionStyle = .none
	}
	
	public var title: String? {
		get {
			return label.text
		}
		set {
			label.text = newValue
		}
	}
	
	public var checked: Bool = false {
		didSet {
			cbImage.image = checked ? #imageLiteral(resourceName: "Checkbox_Checked") : #imageLiteral(resourceName: "Checkbox")
		}
	}
}


class LabelCell: UITableViewCell {
	
	@IBOutlet private var label: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		selectionStyle = .none
	}
	
	public var labelText: String? {
		get {
			return label.text
		}
		set {
			label.text = newValue
		}
	}
	
	public var labelTextColor: UIColor? {
		get {
			return label.textColor
		}
		set {
			label.textColor = newValue ?? .darkText
		}
	}
}
