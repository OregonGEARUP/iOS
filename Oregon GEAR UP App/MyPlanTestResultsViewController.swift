//
//  MyPlanTestResultsViewController.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 5/8/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import UIKit


class MyPlanTestResultsViewController: MyPlanBaseViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
	
	override func dateChanged(_ date: Date, forButton dateButton: UIButton) {
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .long
		dateFormatter.timeStyle = .none
		let strDate = dateFormatter.string(from: date)
		
		dateButton.setTitle(strDate, for: .normal)
		dateButton.setTitleColor(.darkText, for: .normal)
		
		if let indexPath = tableView.indexPathForRow(at: dateButton.convert(dateButton.frame.origin, to: tableView)) {
			switch indexPath.section {
			case 0:	MyPlanManager.shared.testResults.actDate = date
			case 1:	MyPlanManager.shared.testResults.satDate = date
			default: break
			}
		}
	}
	
	public func textFieldDidEndEditing(_ textField: UITextField) {
		
		if let indexPath = tableView.indexPathForRow(at: textField.convert(textField.frame.origin, to: tableView)) {
			if let text = textField.text, let score = Int(text) {
				
				switch (indexPath.section, indexPath.row) {
				case (0,2): MyPlanManager.shared.testResults.actComposite = score
				case (0,3): MyPlanManager.shared.testResults.actMath = score
				case (0,4): MyPlanManager.shared.testResults.actScience = score
				case (0,5): MyPlanManager.shared.testResults.actReading = score
				case (0,6): MyPlanManager.shared.testResults.actWriting = score
					
				case (1,2): MyPlanManager.shared.testResults.satTotal = score
				case (1,3): MyPlanManager.shared.testResults.satReadingWriting = score
				case (1,4): MyPlanManager.shared.testResults.satMath = score
				case (1,5): MyPlanManager.shared.testResults.satEssay = score
					
				default: break
				}
			}
		}
	}
	
	
	// MARK: - lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "Tests"
		
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
	
	private dynamic func keyboardDidShow(_ notification: Notification) {
		
		doneWithDatePicker()
		
		guard let userInfo = notification.userInfo, let r = userInfo[UIKeyboardFrameEndUserInfoKey] else {
			return
		}
		
		let kbHeight = (r as AnyObject).cgRectValue.size.height
		tableViewBottomConstraint.constant = kbHeight - 40.0	// allow for tab bar height
	}
	
	private dynamic func keyboardDidHide(_ notification: Notification) {
		
		tableViewBottomConstraint.constant = 0.0
	}
	
	
    // MARK: - Table view data source
	
	@IBOutlet var tableView: UITableView!
	@IBOutlet var tableViewBottomConstraint: NSLayoutConstraint!

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
	
	public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		switch section {
		case 0:	return "ACT"
		case 1: return "SAT"
		default:
			return nil
		}
	}
	
	public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 200.0, height: 30.0))
		headerView.backgroundColor = UIColor(red: 0x8c/255.0, green: 0xc6/255, blue: 0x3f/255.0, alpha: 1.0)
		
		let titleLabel = UILabel()
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
		titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
		titleLabel.textColor = .white
		headerView.addSubview(titleLabel)
		
		titleLabel.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
		titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
		titleLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 16.0).isActive = true
		
		return headerView
	}
	
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		switch section {
		case 0:	return 7
		case 1: return 6
		default:
			return 0
		}
    }
	
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let testResults = MyPlanManager.shared.testResults
		
		switch indexPath.section {
		case 0:
			switch indexPath.row {
			case 0:
				let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
				if let labelCell = cell as? LabelCell {
					labelCell.labelText = "If you have taken the ACT enter the date and your best scores."
				}
				return cell
			case 1:
				let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
				if let dfCell = cell as? DateFieldCell {
					dfCell.dateField.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
					dfCell.setDate(testResults.actDateDescription)
				}
				return cell
			case 2:
				let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
				if let tfCell = cell as? TextFieldCell {
					tfCell.textField.placeholder = "Composite Score"
					tfCell.textField.text = testResults.actComposite != nil ? "\(testResults.actComposite!)" : nil
					tfCell.textField.keyboardType = .numberPad
					tfCell.textField.inputAccessoryView = keyboardAccessoryView
					tfCell.textField.delegate = self
				}
				return cell
			case 3:
				let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
				if let tfCell = cell as? TextFieldCell {
					tfCell.textField.placeholder = "Math Score"
					tfCell.textField.text = testResults.actMath != nil ? "\(testResults.actMath!)" : nil
					tfCell.textField.keyboardType = .numberPad
					tfCell.textField.inputAccessoryView = keyboardAccessoryView
					tfCell.textField.delegate = self
				}
				return cell
			case 4:
				let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
				if let tfCell = cell as? TextFieldCell {
					tfCell.textField.placeholder = "Science Score"
					tfCell.textField.text = testResults.actScience != nil ? "\(testResults.actScience!)" : nil
					tfCell.textField.keyboardType = .numberPad
					tfCell.textField.inputAccessoryView = keyboardAccessoryView
					tfCell.textField.delegate = self
				}
				return cell
			case 5:
				let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
				if let tfCell = cell as? TextFieldCell {
					tfCell.textField.placeholder = "Reading Score"
					tfCell.textField.text = testResults.actReading != nil ? "\(testResults.actReading!)" : nil
					tfCell.textField.keyboardType = .numberPad
					tfCell.textField.inputAccessoryView = keyboardAccessoryView
					tfCell.textField.delegate = self
				}
				return cell
			case 6:
				let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
				if let tfCell = cell as? TextFieldCell {
					tfCell.textField.placeholder = "Writing Score"
					tfCell.textField.text = testResults.actWriting != nil ? "\(testResults.actWriting!)" : nil
					tfCell.textField.keyboardType = .numberPad
					tfCell.textField.inputAccessoryView = keyboardAccessoryView
					tfCell.textField.delegate = self
				}
				return cell
			default:
				fatalError()
			}
			
		case 1:
			switch indexPath.row {
			case 0:
				let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
				if let labelCell = cell as? LabelCell {
					labelCell.labelText = "If you have taken the SAT enter the date and your best scores."
				}
				return cell
			case 1:
				let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
				if let dfCell = cell as? DateFieldCell {
					dfCell.dateField.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
					dfCell.setDate(testResults.satDateDescription)
				}
				return cell
			case 2:
				let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
				if let tfCell = cell as? TextFieldCell {
					tfCell.textField.placeholder = "Total Score"
					tfCell.textField.text = testResults.satTotal != nil ? "\(testResults.satTotal!)" : nil
					tfCell.textField.keyboardType = .numberPad
					tfCell.textField.inputAccessoryView = keyboardAccessoryView
					tfCell.textField.delegate = self
				}
				return cell
			case 3:
				let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
				if let tfCell = cell as? TextFieldCell {
					tfCell.textField.placeholder = "Reading/Writing Score"
					tfCell.textField.text = testResults.satReadingWriting != nil ? "\(testResults.satReadingWriting!)" : nil
					tfCell.textField.keyboardType = .numberPad
					tfCell.textField.inputAccessoryView = keyboardAccessoryView
					tfCell.textField.delegate = self
				}
				return cell
			case 4:
				let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
				if let tfCell = cell as? TextFieldCell {
					tfCell.textField.placeholder = "Math Score"
					tfCell.textField.text = testResults.satMath != nil ? "\(testResults.satMath!)" : nil
					tfCell.textField.keyboardType = .numberPad
					tfCell.textField.inputAccessoryView = keyboardAccessoryView
					tfCell.textField.delegate = self
				}
				return cell
			case 5:
				let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
				if let tfCell = cell as? TextFieldCell {
					tfCell.textField.placeholder = "Essay Score"
					tfCell.textField.text = testResults.satEssay != nil ? "\(testResults.satEssay!)" : nil
					tfCell.textField.keyboardType = .numberPad
					tfCell.textField.inputAccessoryView = keyboardAccessoryView
					tfCell.textField.delegate = self
				}
				return cell
			default:
				fatalError()
			}
			
		default:
			fatalError()
		}
	}
}
