//
//  MyPlanCollegesViewController.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 5/8/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import UIKit


class MyPlanCollegesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
	
	// MARK: date picker support
	
	private let datePickerPaletteHeight: CGFloat = 200.0
	private var datePickerPaletteView: UIView!
	private var datePicker: UIDatePicker!
	private var datePickerTopConstraint: NSLayoutConstraint!
	private var currentInputDate: UIButton?
	
	private func createDatePickerPaletteView() {
		
		datePickerPaletteView = UIView()
		datePickerPaletteView.translatesAutoresizingMaskIntoConstraints = false
		datePickerPaletteView.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 1.0, alpha: 1.0)
		view.addSubview(datePickerPaletteView)
		datePickerTopConstraint = datePickerPaletteView.topAnchor.constraint(equalTo: view.bottomAnchor)
		NSLayoutConstraint.activate([
			datePickerPaletteView.widthAnchor.constraint(equalTo: view.widthAnchor),
			datePickerPaletteView.heightAnchor.constraint(equalToConstant: datePickerPaletteHeight),
			datePickerPaletteView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			datePickerTopConstraint
		])
		
		let topLine = UIView()
		topLine.translatesAutoresizingMaskIntoConstraints = false
		topLine.backgroundColor = .gray
		datePickerPaletteView.addSubview(topLine)
		NSLayoutConstraint.activate([
			topLine.topAnchor.constraint(equalTo: datePickerPaletteView.topAnchor),
			topLine.widthAnchor.constraint(equalTo: datePickerPaletteView.widthAnchor),
			topLine.heightAnchor.constraint(equalToConstant: 0.5)
		])
		
		datePicker = UIDatePicker()
		datePicker.translatesAutoresizingMaskIntoConstraints = false
		datePicker.addTarget(self, action: #selector(datePickerChanged(_:)), for: UIControlEvents.valueChanged)
		datePicker.datePickerMode = .date
		datePickerPaletteView.addSubview(datePicker)
		NSLayoutConstraint.activate([
			datePicker.topAnchor.constraint(equalTo: datePickerPaletteView.topAnchor, constant: 16.0),
			datePicker.centerXAnchor.constraint(equalTo: datePickerPaletteView.centerXAnchor)
		])
		
		let doneBtn = UIButton(type: .system)
		doneBtn.translatesAutoresizingMaskIntoConstraints = false
		doneBtn.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
		doneBtn.addTarget(self, action: #selector(doneWithDatePicker), for: .touchUpInside)
		datePickerPaletteView.addSubview(doneBtn)
		NSLayoutConstraint.activate([
			doneBtn.topAnchor.constraint(equalTo: datePickerPaletteView.topAnchor, constant: 2.0),
			doneBtn.rightAnchor.constraint(equalTo: datePickerPaletteView.rightAnchor, constant: -20.0)
		])
	}
	
	private dynamic func toggleDatePicker(_ button: UIButton) {
		
		// hide keyboard first
		doneWithKeyboard(btn: nil)
		
		// track whether picker will become visible
		let datePickerVisible = (datePickerTopConstraint.constant == 0)
		
		if datePickerVisible {
			
			let dateFormatter = DateFormatter()
			dateFormatter.dateStyle = .long
			dateFormatter.timeStyle = .none
			
			if let dateStr = button.title(for: .normal),
				let date = dateFormatter.date(from: dateStr) {
				
				datePicker.date = date
			}
		}
		
		view.layoutIfNeeded()
		UIView.animate(withDuration: 0.3, animations: {
			self.datePickerTopConstraint.constant = (self.datePickerTopConstraint.constant == 0 ? -(self.datePickerPaletteHeight + 50.0) : 0.0)
			self.view.layoutIfNeeded()
		})
		
		// keep track of which button triggered the date picker
		currentInputDate = (datePickerVisible ? button : nil)
	}
	
	private dynamic func doneWithDatePicker() {
		
		view.layoutIfNeeded()
		UIView.animate(withDuration: 0.3, animations: {
			self.datePickerTopConstraint.constant = 0.0
			self.view.layoutIfNeeded()
		})
		
		currentInputDate = nil
	}
	
	func datePickerChanged(_ datePicker: UIDatePicker) {
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .long
		dateFormatter.timeStyle = .none
		let strDate = dateFormatter.string(from: datePicker.date)
		
		if let dateButton = currentInputDate {
			dateButton.setTitle(strDate, for: .normal)
			dateButton.setTitleColor(.darkText, for: .normal)
			
			if let indexPath = tableView.indexPathForRow(at: dateButton.convert(dateButton.frame.origin, to: tableView)) {
				MyPlanManager.shared.colleges[indexPath.section / 3].applicationDate = datePicker.date
			}
		}
	}
	
	
	// MARK: - text field keyboard handling
	
	private var keyboardAccessoryView: UIView!

	private func createKeyboardAccessoryView() {
		
		// add a done button for the keyboard
		keyboardAccessoryView = UIView(frame: CGRect(x:0.0, y:0.0, width:0.0, height:40.0))
		keyboardAccessoryView.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 1.0, alpha: 1.0)
		
		let topLine = UIView()
		topLine.translatesAutoresizingMaskIntoConstraints = false
		topLine.backgroundColor = .gray
		keyboardAccessoryView.addSubview(topLine)
		
//		let prevBtn = UIButton(type: .system)
//		prevBtn.translatesAutoresizingMaskIntoConstraints = false
//		prevBtn.setTitle("<", for: .normal)
//		prevBtn.addTarget(self, action: #selector(previousField(btn:)), for: .touchUpInside)
//		keyboardAccessoryView.addSubview(prevBtn)
//		
//		let nextBtn = UIButton(type: .system)
//		nextBtn.translatesAutoresizingMaskIntoConstraints = false
//		nextBtn.setTitle(">", for: .normal)
//		nextBtn.addTarget(self, action: #selector(nextField(btn:)), for: .touchUpInside)
//		keyboardAccessoryView.addSubview(nextBtn)
		
		let doneBtn = UIButton(type: .system)
		doneBtn.translatesAutoresizingMaskIntoConstraints = false
		doneBtn.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
		doneBtn.addTarget(self, action: #selector(doneWithKeyboard(btn:)), for: .touchUpInside)
		keyboardAccessoryView.addSubview(doneBtn)
		
		NSLayoutConstraint.activate([
			topLine.topAnchor.constraint(equalTo: keyboardAccessoryView.topAnchor),
			topLine.widthAnchor.constraint(equalTo: keyboardAccessoryView.widthAnchor),
			topLine.heightAnchor.constraint(equalToConstant: 0.5),
//			prevBtn.topAnchor.constraint(equalTo: keyboardAccessoryView.topAnchor),
//			prevBtn.bottomAnchor.constraint(equalTo: keyboardAccessoryView.bottomAnchor),
//			prevBtn.leadingAnchor.constraint(equalTo: keyboardAccessoryView.leadingAnchor, constant: 20.0),
//			nextBtn.topAnchor.constraint(equalTo: keyboardAccessoryView.topAnchor),
//			nextBtn.bottomAnchor.constraint(equalTo: keyboardAccessoryView.bottomAnchor),
//			nextBtn.leadingAnchor.constraint(equalTo: prevBtn.trailingAnchor, constant: 20.0),
			doneBtn.topAnchor.constraint(equalTo: keyboardAccessoryView.topAnchor),
			doneBtn.bottomAnchor.constraint(equalTo: keyboardAccessoryView.bottomAnchor),
			doneBtn.trailingAnchor.constraint(equalTo: keyboardAccessoryView.trailingAnchor, constant: -20.0)
		])
	}
	
	public func textFieldDidBeginEditing(_ textField: UITextField) {
		
	}

	public func textFieldDidEndEditing(_ textField: UITextField) {
		
		if let indexPath = tableView.indexPathForRow(at: textField.convert(textField.frame.origin, to: tableView)) {
			if let text = textField.text {
				
				let collegeSection = indexPath.section % 3
				switch (collegeSection, indexPath.row) {
				case (0,0): MyPlanManager.shared.colleges[indexPath.section / 3].name = text
				case (1,1): MyPlanManager.shared.colleges[indexPath.section / 3].averageNetPriceDescription = text
				case (2,7): MyPlanManager.shared.colleges[indexPath.section / 3].applicationCostDescription = text
				default:
					break
				}
			}
		}
	}
	
	private dynamic func doneWithKeyboard(btn: UIButton?) {
		
		self.view.endEditing(true)
	}
	
	
	// MARK: - lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "Colleges"
		
		createKeyboardAccessoryView()
		createDatePickerPaletteView()
		
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
        return MyPlanManager.shared.colleges.count * 3
    }
	
	public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		let collegeSection = section % 3
		
		switch collegeSection {
		case 0:	return "College #1"
		case 1: return "Application Deadline"
		case 2: return "What I Need to Apply"
		default:
			return nil
		}
	}
	
	public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		let collegeSection = section % 3
		
		if collegeSection == 0 {
			let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 200.0, height: 30.0))
			headerView.backgroundColor = UIColor(red: 1.0, green: 0.8, blue: 1.0, alpha: 1.0)
			
			let titleLabel = UILabel()
			titleLabel.translatesAutoresizingMaskIntoConstraints = false
			titleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
			titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
			titleLabel.textColor = .darkText
			headerView.addSubview(titleLabel)
			
			titleLabel.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
			titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
			titleLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 16.0).isActive = true
			
			return headerView
		}
		
		return nil
	}
	
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		let collegeSection = section % 3
		
		switch collegeSection {
		case 0:	return 1
		case 1: return 2
		case 2: return 9
		default:
			return 0
		}
    }
	
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let college = MyPlanManager.shared.colleges[indexPath.section / 3]
		let collegeSection = indexPath.section % 3
		
		switch collegeSection {
		case 0:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let textField = cell.viewWithTag(100) as? UITextField {
				textField.placeholder = "College Name"
				textField.text = college.name
				textField.inputAccessoryView = keyboardAccessoryView
				textField.delegate = self
			}
			cell.selectionStyle = .none
			return cell
		case 1:
			if indexPath.row == 0 {
				let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
				if let dateButton = cell.viewWithTag(300) as? UIButton {
					dateButton.layer.backgroundColor = UIColor.white.cgColor
					dateButton.layer.borderColor = UIColor(white: 0.8, alpha: 1.0).cgColor
					dateButton.layer.borderWidth = 0.5
					dateButton.layer.cornerRadius = 5.0
					dateButton.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
					if let dateText = college.applicationDateDescription {
						dateButton.setTitle(dateText, for: .normal)
						dateButton.setTitleColor(.darkText, for: .normal)
					} else {
						dateButton.setTitle("tap to select date", for: .normal)
						dateButton.setTitleColor(UIColor.init(white: 0.8, alpha: 1.0), for: .normal)
					}
				}
				cell.selectionStyle = .none
				return cell
			} else {
				let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
				if let textField = cell.viewWithTag(100) as? UITextField {
					textField.placeholder = "Average Net Price"
					textField.text = college.averageNetPriceDescription
					textField.keyboardType = .decimalPad
					textField.inputAccessoryView = keyboardAccessoryView
					textField.delegate = self
				}
				cell.selectionStyle = .none
				return cell
			}
		case 2:
			if indexPath.row != 7 {
				let cell = tableView.dequeueReusableCell(withIdentifier: "checkbox", for: indexPath)
				if let label = cell.viewWithTag(201) as? UILabel {
					switch indexPath.row {
					case 0:	label.text = "Essay or personal statement"
					case 1:	label.text = "Letter(s) of recommendation"
					case 2:	label.text = "Activities chart or resume"
					case 3:	label.text = "SAT or ACT"
					case 4:	label.text = "Additional financial aid form"
					case 5:	label.text = "Additional scholarship application"
					case 6:	label.text = "Fee deferral or waiver"
					case 8:	label.text = "I applied!"
					default: break
					}
				}
				if let cbImageView = cell.viewWithTag(200) as? UIImageView {
					switch indexPath.row {
					case 0:	cbImageView.image = college.essayDone ? #imageLiteral(resourceName: "Checkbox_Checked") : #imageLiteral(resourceName: "Checkbox")
					case 1:	cbImageView.image = college.recommendationsDone ? #imageLiteral(resourceName: "Checkbox_Checked") : #imageLiteral(resourceName: "Checkbox")
					case 2:	cbImageView.image = college.activitiesChartDone ? #imageLiteral(resourceName: "Checkbox_Checked") : #imageLiteral(resourceName: "Checkbox")
					case 3:	cbImageView.image = college.testsDone ? #imageLiteral(resourceName: "Checkbox_Checked") : #imageLiteral(resourceName: "Checkbox")
					case 4:	cbImageView.image = college.addlFinancialAidDone ? #imageLiteral(resourceName: "Checkbox_Checked") : #imageLiteral(resourceName: "Checkbox")
					case 5:	cbImageView.image = college.addlScholarshipDone ? #imageLiteral(resourceName: "Checkbox_Checked") : #imageLiteral(resourceName: "Checkbox")
					case 6:	cbImageView.image = college.feeDeferralDone ? #imageLiteral(resourceName: "Checkbox_Checked") : #imageLiteral(resourceName: "Checkbox")
					case 8:	cbImageView.image = college.applicationDone ? #imageLiteral(resourceName: "Checkbox_Checked") : #imageLiteral(resourceName: "Checkbox")
					default: break
					}
				}
				cell.selectionStyle = .none
				return cell
			} else {
				let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
				if let textField = cell.viewWithTag(100) as? UITextField {
					textField.placeholder = "Cost to Apply"
					textField.text = college.applicationCostDescription
					textField.keyboardType = .decimalPad
					textField.inputAccessoryView = keyboardAccessoryView
					textField.delegate = self
				}
				cell.selectionStyle = .none
				return cell
			}
		default:
			fatalError()
		}
    }
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		if let cell = tableView.cellForRow(at: indexPath),
			let cbImageView = cell.viewWithTag(200) as? UIImageView {
			
			var college = MyPlanManager.shared.colleges[indexPath.section / 3]
			
			switch indexPath.row {
			case 0:	college.essayDone = !college.essayDone;							cbImageView.image = college.essayDone ? #imageLiteral(resourceName: "Checkbox_Checked") : #imageLiteral(resourceName: "Checkbox")
			case 1:	college.recommendationsDone = !college.recommendationsDone;		cbImageView.image = college.recommendationsDone ? #imageLiteral(resourceName: "Checkbox_Checked") : #imageLiteral(resourceName: "Checkbox")
			case 2:	college.activitiesChartDone = !college.activitiesChartDone;		cbImageView.image = college.activitiesChartDone ? #imageLiteral(resourceName: "Checkbox_Checked") : #imageLiteral(resourceName: "Checkbox")
			case 3:	college.testsDone = !college.testsDone;							cbImageView.image = college.testsDone ? #imageLiteral(resourceName: "Checkbox_Checked") : #imageLiteral(resourceName: "Checkbox")
			case 4:	college.addlFinancialAidDone = !college.addlFinancialAidDone;	cbImageView.image = college.addlFinancialAidDone ? #imageLiteral(resourceName: "Checkbox_Checked") : #imageLiteral(resourceName: "Checkbox")
			case 5:	college.addlScholarshipDone = !college.addlScholarshipDone;		cbImageView.image = college.addlScholarshipDone ? #imageLiteral(resourceName: "Checkbox_Checked") : #imageLiteral(resourceName: "Checkbox")
			case 6:	college.feeDeferralDone = !college.feeDeferralDone;				cbImageView.image = college.feeDeferralDone ? #imageLiteral(resourceName: "Checkbox_Checked") : #imageLiteral(resourceName: "Checkbox")
			case 8:	college.applicationDone = !college.applicationDone;				cbImageView.image = college.applicationDone ? #imageLiteral(resourceName: "Checkbox_Checked") : #imageLiteral(resourceName: "Checkbox")
			default: break
			}
			
			MyPlanManager.shared.colleges[indexPath.section / 3] = college
		}
	}
}
