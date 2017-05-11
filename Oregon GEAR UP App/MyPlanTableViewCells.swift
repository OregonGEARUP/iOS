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


class DateFieldCell: UITableViewCell {
	
	@IBOutlet var dateField: UIButton!
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
	
	public func setDate(_ dateText: String?) {
		
		if let dateText = dateText {
			dateField.setTitle(dateText, for: .normal)
			dateField.setTitleColor(.darkText, for: .normal)
		} else {
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
