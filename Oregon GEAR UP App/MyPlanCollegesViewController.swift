//
//  MyPlanCollegesViewController.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 5/8/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import UIKit


class MyPlanCollegesViewController: MyPlanBaseViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
	
	private let sectionsPerCollege = 2
	
	
	override func dateChanged(_ date: Date, forIndexPath indexPath: IndexPath) {
		let collegeIndex = indexPath.section / sectionsPerCollege
		MyPlanManager.shared.colleges[collegeIndex].applicationDate = date
	}
	
	public func textFieldDidEndEditing(_ textField: UITextField) {
		
		if let indexPath = tableView.indexPathForRow(at: textField.convert(textField.frame.origin, to: tableView)) {
			if let text = textField.text {
				
				let collegeSection = indexPath.section % sectionsPerCollege
				let collegeIndex = indexPath.section / sectionsPerCollege
				
				switch (collegeSection, indexPath.row) {
				case (0,0):
					MyPlanManager.shared.colleges[collegeIndex].name = text
					tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
				case (0,2): MyPlanManager.shared.colleges[collegeIndex].averageNetPrice = Double(currencyDescription: text)
				case (1,7): MyPlanManager.shared.colleges[collegeIndex].applicationCost = Double(currencyDescription: text)
				default:
					break
				}
				
				tableView.reloadRows(at: [indexPath], with: .automatic)
			}
		}
	}
	
	
	// MARK: - add/remove college
	
	private dynamic func addCollege() {
		
		let alertController = UIAlertController(title: "Add College", message: "Please enter the name of the college.", preferredStyle: .alert)
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alertController.addAction(cancelAction)
		
		let addAction = UIAlertAction(title: "Add", style: .default, handler: { (action) in
			if let name = alertController.textFields?[0].text {
				
				MyPlanManager.shared.addCollege(withName: name)
				self.tableView.reloadData()
				
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
					self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: (MyPlanManager.shared.colleges.count-1) * self.sectionsPerCollege), at: .top, animated: true)
				}
			}
		})
		addAction.isEnabled = false
		alertController.addAction(addAction)
		
		alertController.addTextField(configurationHandler: { (textField) in
			textField.placeholder = "college name"
			
			NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main, using: { (notification) in
				if let text = textField.text {
					addAction.isEnabled = !text.isEmpty
				} else {
					addAction.isEnabled = false
				}
			})
		})
		
		present(alertController, animated: true, completion: nil)
	}
	
	private dynamic func removeCollege(_ button: UIButton) {
		
		if let indexPath = tableView.indexPathForRow(at: button.convert(button.frame.origin, to: tableView)) {
			
			let collegeIndex = indexPath.section / sectionsPerCollege
			let collegeName = MyPlanManager.shared.colleges[collegeIndex].name
			
			let alertController = UIAlertController(title: "Remove College", message: "Confirm removing \(collegeName) from your college list.", preferredStyle: .alert)
			
			let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
			alertController.addAction(cancelAction)
			
			let removeAction = UIAlertAction(title: "Remove", style: .destructive, handler: { (action) in
				
				MyPlanManager.shared.removeCollege(at: collegeIndex)
				self.tableView.reloadData()
				
				let scrollToIndex = collegeIndex > 0 ? collegeIndex-1 : collegeIndex
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
					self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: scrollToIndex * self.sectionsPerCollege), at: .top, animated: true)
				}
			})
			alertController.addAction(removeAction)
			
			present(alertController, animated: true, completion: nil)
		}
	}
	
	
	// MARK: - lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "Colleges"
		
		tableView.delegate = self
		tableView.dataSource = self
		//tableView.rowHeight = UITableViewAutomaticDimension
		
		//let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCollege))
		let addBtn = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addCollege))
		self.navigationItem.setRightBarButton(addBtn, animated: false)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		MyPlanManager.shared.checkFirstCollegeName()
		tableView.reloadData()
		
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
	
    public func numberOfSections(in tableView: UITableView) -> Int {
        return MyPlanManager.shared.colleges.count * sectionsPerCollege
    }
	
	public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		let collegeIndex = (section / sectionsPerCollege)
		let collegeSection = section % sectionsPerCollege
		
		switch collegeSection {
		case 0:
			let college = MyPlanManager.shared.colleges[collegeIndex]
			return college.name
		case 1: return "What I Need to Apply"
		default:
			return nil
		}
	}
	
	public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		let collegeSection = section % sectionsPerCollege
		
		if collegeSection == 0 {
			let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 200.0, height: 40.0))
			headerView.backgroundColor = StyleGuide.myPlanColor
			
			let titleLabel = UILabel()
			titleLabel.translatesAutoresizingMaskIntoConstraints = false
			titleLabel.font = UIFont.boldSystemFont(ofSize: 19.0)
			titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
			titleLabel.textColor = .white
			headerView.addSubview(titleLabel)
			
			titleLabel.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
			titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
			titleLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 16.0).isActive = true
			
			return headerView
		}
		
		return nil
	}
	
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		let collegeSection = section % sectionsPerCollege
		switch collegeSection {
		case 0:	return 4
		case 1: return MyPlanManager.shared.colleges.count > 1 ? 9 : 8		// no Remove button when just one college
		default:
			return 0
		}
    }
	
	public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		let collegeSection = indexPath.section % sectionsPerCollege
		if collegeSection == 1 && indexPath.row <= 6 {
			return 40
		}
		
		return 60
	}
	
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let college = MyPlanManager.shared.colleges[indexPath.section / sectionsPerCollege]
		let collegeSection = indexPath.section % sectionsPerCollege
		
		switch collegeSection {
		case 0:
			if indexPath.row == 0 {
				let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
				if let tfCell = cell as? TextFieldCell {
					tfCell.textField.placeholder = "college name"
					tfCell.prompt = "Name"
					tfCell.textField.text = college.name
					tfCell.textField.keyboardType = .default
					tfCell.textField.inputAccessoryView = keyboardAccessoryView
					tfCell.textField.delegate = self
				}
				return cell
			} else if indexPath.row == 1 {
				let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
				if let dfCell = cell as? DateFieldCell {
					dfCell.dateField.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
					dfCell.setDate(college.applicationDate)
					dfCell.prompt = "Application Deadline"
				}
				return cell
			} else if indexPath.row == 2 {
				let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
				if let tfCell = cell as? TextFieldCell {
					tfCell.textField.placeholder = "average net price"
					tfCell.prompt = "Net Price"
					tfCell.textField.text = college.averageNetPrice?.currencyDescription
					tfCell.textField.keyboardType = .decimalPad
					tfCell.textField.inputAccessoryView = keyboardAccessoryView
					tfCell.textField.delegate = self
				}
				return cell
			} else {
				let cell = tableView.dequeueReusableCell(withIdentifier: "checkbox", for: indexPath)
				if let cbCell = cell as? CheckboxCell {
					cbCell.title = "I applied!"
					cbCell.checked = college.applicationDone
				}
				return cell
			}
		case 1:
			if indexPath.row == 7 {
				let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
				if let tfCell = cell as? TextFieldCell {
					tfCell.textField.placeholder = "cost to apply"
					tfCell.prompt = "Application Cost"
					tfCell.textField.text = college.applicationCost?.currencyDescription
					tfCell.textField.keyboardType = .decimalPad
					tfCell.textField.inputAccessoryView = keyboardAccessoryView
					tfCell.textField.delegate = self
				}
				return cell
			} else if indexPath.row == 8 {
				let cell = tableView.dequeueReusableCell(withIdentifier: "button", for: indexPath)
				if let btnCell = cell as? ButtonCell {
					btnCell.button.setTitle("Remove This College", for: .normal)
					btnCell.button.addTarget(self, action: #selector(removeCollege(_:)), for: .touchUpInside)
				}
				return cell
			} else {
				let cell = tableView.dequeueReusableCell(withIdentifier: "checkbox", for: indexPath)
				if let cbCell = cell as? CheckboxCell {
					switch indexPath.row {
					case 0:
						cbCell.title = "Essay or personal statement"
						cbCell.checked = college.essayDone
					case 1:
						cbCell.title = "Letter(s) of recommendation"
						cbCell.checked = college.recommendationsDone
					case 2:
						cbCell.title = "Activities chart or resume"
						cbCell.checked = college.activitiesChartDone
					case 3:
						cbCell.title = "SAT or ACT"
						cbCell.checked = college.testsDone
					case 4:
						cbCell.title = "Additional financial aid form"
						cbCell.checked = college.addlFinancialAidDone
					case 5:
						cbCell.title = "Additional scholarship application"
						cbCell.checked = college.addlScholarshipDone
					case 6:
						cbCell.title = "Fee deferral or waiver"
						cbCell.checked = college.feeDeferralDone
					default: break
					}
				}
				return cell
			}
		default:
			fatalError()
		}
    }
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		if let cbCell = tableView.cellForRow(at: indexPath) as? CheckboxCell {
			
			let collegeSection = indexPath.section % sectionsPerCollege
			var college = MyPlanManager.shared.colleges[indexPath.section / sectionsPerCollege]
			
			if collegeSection == 0 {
				college.applicationDone = !college.applicationDone
				cbCell.checked = college.applicationDone
			} else {
				switch indexPath.row {
				case 0:
					college.essayDone = !college.essayDone
					cbCell.checked = college.essayDone
				case 1:
					college.recommendationsDone = !college.recommendationsDone
					cbCell.checked = college.recommendationsDone
				case 2:
					college.activitiesChartDone = !college.activitiesChartDone
					cbCell.checked = college.activitiesChartDone
				case 3:
					college.testsDone = !college.testsDone
					cbCell.checked = college.testsDone
				case 4:
					college.addlFinancialAidDone = !college.addlFinancialAidDone
					cbCell.checked = college.addlFinancialAidDone
				case 5:
					college.addlScholarshipDone = !college.addlScholarshipDone
					cbCell.checked = college.addlScholarshipDone
				case 6:
					college.feeDeferralDone = !college.feeDeferralDone
					cbCell.checked = college.feeDeferralDone
				default:
					break
				}
			}
			
			MyPlanManager.shared.colleges[indexPath.section / sectionsPerCollege] = college
		}
	}
}
