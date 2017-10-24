//
//  MyPlanResidencyViewController.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 5/13/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import UIKit


class MyPlanResidencyViewController: MyPlanBaseViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
	
	override func dateChanged(_ date: Date, forIndexPath indexPath: IndexPath) {
		
		switch indexPath.row {
		case 3:  MyPlanManager.shared.residency.residencyStart = date
		case 4:  MyPlanManager.shared.residency.residencyEnd = date
		case 6:  MyPlanManager.shared.residency.parentResidencyStart = date
		case 7:  MyPlanManager.shared.residency.parentResidencyEnd = date
			
		case 10: MyPlanManager.shared.residency.registerToVote = date
		case 12: MyPlanManager.shared.residency.parentsRegisterToVote = date
			
		case 15: MyPlanManager.shared.residency.militaryServiceStart = date
		case 16: MyPlanManager.shared.residency.militaryServiceEnd = date
		case 18: MyPlanManager.shared.residency.parentMilitaryServiceStart = date
		case 19: MyPlanManager.shared.residency.parentMilitaryServiceEnd = date
			
		case 22: MyPlanManager.shared.residency.fileOregonTaxesYear1 = date
		case 23: MyPlanManager.shared.residency.fileOregonTaxesYear2 = date
		case 25: MyPlanManager.shared.residency.parentsFileOregonTaxesYear1 = date
		case 26: MyPlanManager.shared.residency.parentsFileOregonTaxesYear2 = date
			
		case 31: MyPlanManager.shared.residency.startEmployer1 = date
		case 32: MyPlanManager.shared.residency.endEmployer1 = date
		case 36: MyPlanManager.shared.residency.startEmployer2 = date
		case 37: MyPlanManager.shared.residency.endEmployer2 = date
			
		case 41: MyPlanManager.shared.residency.parentStartEmployer1 = date
		case 42: MyPlanManager.shared.residency.parentEndEmployer1 = date
		case 46: MyPlanManager.shared.residency.parentStartEmployer2 = date
		case 47: MyPlanManager.shared.residency.parentEndEmployer2 = date
			
		default: break
		}
	}
	
	public func textFieldDidEndEditing(_ textField: UITextField) {
		
		if let indexPath = tableView.indexPathForRow(at: textField.convert(textField.frame.origin, to: tableView)) {
			
			switch indexPath.row {
			case 29: MyPlanManager.shared.residency.nameEmployer1 = textField.text
			case 30: MyPlanManager.shared.residency.cityEmployer1 = textField.text
			case 34: MyPlanManager.shared.residency.nameEmployer2 = textField.text
			case 35: MyPlanManager.shared.residency.cityEmployer2 = textField.text
				
			case 39: MyPlanManager.shared.residency.parentNameEmployer1 = textField.text
			case 40: MyPlanManager.shared.residency.parentCityEmployer1 = textField.text
			case 44: MyPlanManager.shared.residency.parentNameEmployer2 = textField.text
			case 45: MyPlanManager.shared.residency.parentCityEmployer2 = textField.text
			
			default: break
			}
		}
	}
	
	
	// MARK: - lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "Residency Info"
		
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 50
		
		tableView.delegate = self
		tableView.dataSource = self
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		NotificationCenter.default.addObserver(self, selector:#selector(keyboardDidShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector:#selector(keyboardDidHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
		
		doneWithKeyboard(btn: nil)
		doneWithDatePicker()
	}
	
	@objc private func keyboardDidShow(_ notification: Notification) {
		
		doneWithDatePicker()
		
		guard let userInfo = notification.userInfo, let r = userInfo[UIKeyboardFrameEndUserInfoKey] else {
			return
		}
		
		let kbHeight = (r as AnyObject).cgRectValue.size.height
		tableViewBottomConstraint.constant = kbHeight - 40.0	// allow for tab bar height
	}
	
	@objc private func keyboardDidHide(_ notification: Notification) {
		
		tableViewBottomConstraint.constant = 0.0
	}
	
	
    // MARK: - Table view data source
	
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return 48
	}
	
	private let bgColor = StyleGuide.myPlanColor
	
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let residency = MyPlanManager.shared.residency
		
		switch indexPath.row {
		case 0:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "If you apply to an Oregon public university you will need to answer questions about how long you and your parent/guardian have lived in the state."
				labelCell.contentView.backgroundColor = nil
				labelCell.labelTextColor = nil
			}
			return cell
			
		// Oregon residency
		case 1:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "Residency Info"
				labelCell.contentView.backgroundColor = bgColor
				labelCell.labelTextColor = .white
			}
			return cell
		case 2:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "How long have you lived here? If you were born in Oregon, list the month and year of your birthday."
				labelCell.contentView.backgroundColor = nil
				labelCell.labelTextColor = nil
			}
			return cell
		case 3:
			let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
			if let dfCell = cell as? DateFieldCell {
				dfCell.placeholderText = "residency start date"
				dfCell.prompt = "Start"
				dfCell.dateField.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
				dfCell.setDate(residency.residencyStart, type: .monthYear)
			}
			return cell
		case 4:
			let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
			if let dfCell = cell as? DateFieldCell {
				dfCell.placeholderText = "residency end date"
				dfCell.prompt = "End"
				dfCell.dateField.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
				dfCell.setDate(residency.residencyEnd, type: .monthYear)
			}
			return cell
			
		// parents Oregon residency
		case 5:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "How long has your parent/guardian lived here?"
				labelCell.contentView.backgroundColor = nil
				labelCell.labelTextColor = nil
			}
			return cell
		case 6:
			let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
			if let dfCell = cell as? DateFieldCell {
				dfCell.placeholderText = "residency start date"
				dfCell.prompt = "Start"
				dfCell.dateField.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
				dfCell.setDate(residency.parentResidencyStart, type: .monthYear)
			}
			return cell
		case 7:
			let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
			if let dfCell = cell as? DateFieldCell {
				dfCell.placeholderText = "residency end date"
				dfCell.prompt = "End"
				dfCell.dateField.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
				dfCell.setDate(residency.parentResidencyEnd, type: .monthYear)
			}
			return cell
			
		// register to vote
		case 8:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "Voter Registration"
				labelCell.contentView.backgroundColor = bgColor
				labelCell.labelTextColor = .white
			}
			return cell
		case 9:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "When did you register to vote?"
				labelCell.contentView.backgroundColor = nil
				labelCell.labelTextColor = nil
			}
			return cell
		case 10:
			let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
			if let dfCell = cell as? DateFieldCell {
				dfCell.placeholderText = "registration date"
				dfCell.prompt = "Date"
				dfCell.dateField.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
				dfCell.setDate(residency.registerToVote, type: .monthYear)
			}
			return cell
		
		// parents register to vote
		case 11:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "When did your parent/guardian register to vote?"
				labelCell.contentView.backgroundColor = nil
				labelCell.labelTextColor = nil
			}
			return cell
		case 12:
			let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
			if let dfCell = cell as? DateFieldCell {
				dfCell.placeholderText = "registration date"
				dfCell.prompt = "Date"
				dfCell.dateField.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
				dfCell.setDate(residency.parentsRegisterToVote, type: .monthYear)
			}
			return cell
			
		// military service
		case 13:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "Military Service"
				labelCell.contentView.backgroundColor = bgColor
				labelCell.labelTextColor = .white
			}
			return cell
		case 14:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "Have you entered military service from Oregon?"
				labelCell.contentView.backgroundColor = nil
				labelCell.labelTextColor = nil
			}
			return cell
		case 15:
			let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
			if let dfCell = cell as? DateFieldCell {
				dfCell.placeholderText = "service start date"
				dfCell.prompt = "Start"
				dfCell.dateField.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
				dfCell.setDate(residency.militaryServiceStart, type: .monthYear)
			}
			return cell
		case 16:
			let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
			if let dfCell = cell as? DateFieldCell {
				dfCell.placeholderText = "service end date"
				dfCell.prompt = "End"
				dfCell.dateField.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
				dfCell.setDate(residency.militaryServiceEnd, type: .monthYear)
			}
			return cell
		
		// parents military service
		case 17:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "Has your parent/guardian entered military service from Oregon?"
				labelCell.contentView.backgroundColor = nil
				labelCell.labelTextColor = nil
			}
			return cell
		case 18:
			let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
			if let dfCell = cell as? DateFieldCell {
				dfCell.placeholderText = "service start date"
				dfCell.prompt = "Start"
				dfCell.dateField.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
				dfCell.setDate(residency.parentMilitaryServiceStart, type: .monthYear)
			}
			return cell
		case 19:
			let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
			if let dfCell = cell as? DateFieldCell {
				dfCell.placeholderText = "service end date"
				dfCell.prompt = "End"
				dfCell.dateField.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
				dfCell.setDate(residency.parentMilitaryServiceEnd, type: .monthYear)
			}
			return cell
		
		// Oregon taxes
		case 20:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "Taxes"
				labelCell.contentView.backgroundColor = bgColor
				labelCell.labelTextColor = .white
			}
			return cell
		case 21:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "What are the last two years you filed Oregon income taxes?"
				labelCell.contentView.backgroundColor = nil
				labelCell.labelTextColor = nil
			}
			return cell
		case 22:
			let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
			if let dfCell = cell as? DateFieldCell {
				dfCell.placeholderText = "tax year"
				dfCell.prompt = "Year 1"
				dfCell.dateField.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
				dfCell.setDate(residency.fileOregonTaxesYear1, type: .year)
			}
			return cell
		case 23:
			let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
			if let dfCell = cell as? DateFieldCell {
				dfCell.placeholderText = "tax year"
				dfCell.prompt = "Year 2"
				dfCell.dateField.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
				dfCell.setDate(residency.fileOregonTaxesYear2, type: .year)
			}
			return cell
			
		// parents Oregon taxes
		case 24:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "What are the last two years your parent/guardian filed Oregon income taxes?"
				labelCell.contentView.backgroundColor = nil
				labelCell.labelTextColor = nil
			}
			return cell
		case 25:
			let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
			if let dfCell = cell as? DateFieldCell {
				dfCell.placeholderText = "tax year"
				dfCell.prompt = "Year 1"
				dfCell.dateField.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
				dfCell.setDate(residency.parentsFileOregonTaxesYear1, type: .year)
			}
			return cell
		case 26:
			let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
			if let dfCell = cell as? DateFieldCell {
				dfCell.placeholderText = "tax year"
				dfCell.prompt = "Year 2"
				dfCell.dateField.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
				dfCell.setDate(residency.parentsFileOregonTaxesYear2, type: .year)
			}
			return cell
		
		// current job
		case 27:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "Employment"
				labelCell.contentView.backgroundColor = bgColor
				labelCell.labelTextColor = .white
			}
			return cell
		case 28:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "Do you or did you have a job? List your most recent or current job."
				labelCell.contentView.backgroundColor = nil
				labelCell.labelTextColor = nil
			}
			return cell
		case 29:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.placeholder = "employer name"
				tfCell.prompt = "Name"
				tfCell.textField.text = residency.nameEmployer1
				tfCell.textField.keyboardType = .default
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 30:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.placeholder = "employer city"
				tfCell.prompt = "City"
				tfCell.textField.text = residency.cityEmployer1
				tfCell.textField.keyboardType = .default
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 31:
			let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
			if let dfCell = cell as? DateFieldCell {
				dfCell.placeholderText = "employment start date"
				dfCell.prompt = "Start"
				dfCell.dateField.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
				dfCell.setDate(residency.startEmployer1, type: .monthYear)
			}
			return cell
		case 32:
			let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
			if let dfCell = cell as? DateFieldCell {
				dfCell.placeholderText = "employment end date"
				dfCell.prompt = "End"
				dfCell.dateField.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
				dfCell.setDate(residency.endEmployer1, type: .monthYear)
			}
			return cell
		
		// previous job
		case 33:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "List your previous job, if any."
				labelCell.contentView.backgroundColor = nil
				labelCell.labelTextColor = nil
			}
			return cell
		case 34:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.placeholder = "employer name"
				tfCell.prompt = "Name"
				tfCell.textField.text = residency.nameEmployer2
				tfCell.textField.keyboardType = .default
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 35:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.placeholder = "employer city"
				tfCell.prompt = "City"
				tfCell.textField.text = residency.cityEmployer2
				tfCell.textField.keyboardType = .default
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 36:
			let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
			if let dfCell = cell as? DateFieldCell {
				dfCell.placeholderText = "employment start date"
				dfCell.prompt = "Start"
				dfCell.dateField.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
				dfCell.setDate(residency.startEmployer2, type: .monthYear)
			}
			return cell
		case 37:
			let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
			if let dfCell = cell as? DateFieldCell {
				dfCell.placeholderText = "employment end date"
				dfCell.prompt = "End"
				dfCell.dateField.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
				dfCell.setDate(residency.endEmployer2, type: .monthYear)
			}
			return cell
		
		// parent's current job
		case 38:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "List your parent/guardian's most recent or current job."
				labelCell.contentView.backgroundColor = nil
				labelCell.labelTextColor = nil
			}
			return cell
		case 39:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.placeholder = "employer name"
				tfCell.prompt = "Name"
				tfCell.textField.text = residency.parentNameEmployer1
				tfCell.textField.keyboardType = .default
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 40:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.placeholder = "employer city"
				tfCell.prompt = "City"
				tfCell.textField.text = residency.parentCityEmployer1
				tfCell.textField.keyboardType = .default
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 41:
			let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
			if let dfCell = cell as? DateFieldCell {
				dfCell.placeholderText = "employment start date"
				dfCell.prompt = "Start"
				dfCell.dateField.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
				dfCell.setDate(residency.parentStartEmployer1, type: .monthYear)
			}
			return cell
		case 42:
			let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
			if let dfCell = cell as? DateFieldCell {
				dfCell.placeholderText = "employment end date"
				dfCell.prompt = "End"
				dfCell.dateField.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
				dfCell.setDate(residency.parentEndEmployer1, type: .monthYear)
			}
			return cell
			
		// previous job
		case 43:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "List your parent/guardian's previous job, if any."
				labelCell.contentView.backgroundColor = nil
				labelCell.labelTextColor = nil
			}
			return cell
		case 44:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.placeholder = "employer name"
				tfCell.prompt = "Name"
				tfCell.textField.text = residency.parentNameEmployer2
				tfCell.textField.keyboardType = .default
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 45:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.placeholder = "employer city"
				tfCell.prompt = "City"
				tfCell.textField.text = residency.parentCityEmployer2
				tfCell.textField.keyboardType = .default
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 46:
			let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
			if let dfCell = cell as? DateFieldCell {
				dfCell.placeholderText = "employment start date"
				dfCell.prompt = "Start"
				dfCell.dateField.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
				dfCell.setDate(residency.parentStartEmployer2, type: .monthYear)
			}
			return cell
		case 47:
			let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
			if let dfCell = cell as? DateFieldCell {
				dfCell.placeholderText = "employment end date"
				dfCell.prompt = "End"
				dfCell.dateField.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
				dfCell.setDate(residency.parentEndEmployer2, type: .monthYear)
			}
			return cell
			
		default:
			fatalError()
		}
	}
}
