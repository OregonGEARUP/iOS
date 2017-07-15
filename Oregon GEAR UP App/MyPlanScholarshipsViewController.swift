//
//  MyPlanScholarshipsViewController.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 5/8/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import UIKit


class MyPlanScholarshipsViewController: MyPlanBaseViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
	
	private let sectionsPerScholarship = 3
	
	
	override func dateChanged(_ date: Date, forIndexPath indexPath: IndexPath) {
		
		MyPlanManager.shared.scholarships[indexPath.section / sectionsPerScholarship].applicationDate = date
	}
	
	public func textFieldDidEndEditing(_ textField: UITextField) {
		
		if let indexPath = tableView.indexPathForRow(at: textField.convert(textField.frame.origin, to: tableView)) {
			if let text = textField.text {
				
				let scholarshipSection = indexPath.section % sectionsPerScholarship
				switch (scholarshipSection, indexPath.row) {
				case (0,0): MyPlanManager.shared.scholarships[indexPath.section / sectionsPerScholarship].name = text
				case (1,1): MyPlanManager.shared.scholarships[indexPath.section / sectionsPerScholarship].website = text
				case (2,7): MyPlanManager.shared.scholarships[indexPath.section / sectionsPerScholarship].otherInfo = text
				default:
					break
				}
				
				tableView.reloadRows(at: [indexPath], with: .automatic)
			}
		}
	}
	
	
	// MARK: - add/remove scholarship
	
	private dynamic func addScholarship() {
		
		let alertController = UIAlertController(title: "Add Scholarship", message: "Please enter the name of the scholarship.", preferredStyle: .alert)
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alertController.addAction(cancelAction)
		
		let addAction = UIAlertAction(title: "Add", style: .default, handler: { (action) in
			if let name = alertController.textFields?[0].text {
				
				MyPlanManager.shared.addScholarship(withName: name)
				self.tableView.reloadData()
				
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
					self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: (MyPlanManager.shared.scholarships.count-1) * self.sectionsPerScholarship), at: .top, animated: true)
				}
			}
		})
		addAction.isEnabled = false
		alertController.addAction(addAction)
		
		alertController.addTextField(configurationHandler: { (textField) in
			textField.placeholder = "scholarship name"
			
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
	
	private dynamic func removeScholarship(_ button: UIButton) {
		
		if let indexPath = tableView.indexPathForRow(at: button.convert(button.frame.origin, to: tableView)) {
			
			let scholarshipIndex = indexPath.section / self.sectionsPerScholarship
			let scholarshipName = MyPlanManager.shared.scholarships[scholarshipIndex].name
			
			let alertController = UIAlertController(title: "Remove Scholarship", message: "Confirm removing \(scholarshipName) from your scholarships list.", preferredStyle: .alert)
			
			let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
			alertController.addAction(cancelAction)
			
			let removeAction = UIAlertAction(title: "Remove", style: .destructive, handler: { (action) in
				
				MyPlanManager.shared.removeScholarship(at: scholarshipIndex)
				self.tableView.reloadData()
				
				let scrollToIndex = scholarshipIndex > 0 ? scholarshipIndex-1 : scholarshipIndex
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
					self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: scrollToIndex * self.sectionsPerScholarship), at: .top, animated: true)
				}
			})
			alertController.addAction(removeAction)
			
			present(alertController, animated: true, completion: nil)
		}
	}
	
	
	// MARK: - lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "Scholarships"
		
		tableView.delegate = self
		tableView.dataSource = self
		
		let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addScholarship))
		self.navigationItem.setRightBarButton(addBtn, animated: false)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		MyPlanManager.shared.checkFirstScholarshipName()
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
        return MyPlanManager.shared.scholarships.count * sectionsPerScholarship
    }
	
	public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		let scholarshipNumber = (section / sectionsPerScholarship) + 1
		let scholarshipSection = section % sectionsPerScholarship
		
		switch scholarshipSection {
		case 0:	return "Scholarship #\(scholarshipNumber)"
		case 1: return "Application Deadline"
		case 2: return "What I Need to Apply"
		default:
			return nil
		}
	}
	
	public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		let scholarshipSection = section % sectionsPerScholarship
		
		if scholarshipSection == 0 {
			let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 200.0, height: 30.0))
			headerView.backgroundColor = StyleGuide.completeButtonColor
			
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
		
		return nil
	}
	
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		let scholarshipSection = section % sectionsPerScholarship
		
		switch scholarshipSection {
		case 0:	return 1
		case 1: return 2
		case 2: return MyPlanManager.shared.scholarships.count > 1 ? 7 : 6		// no Remove button when just one scholarship
		default:
			return 0
		}
    }
	
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let scholarship = MyPlanManager.shared.scholarships[indexPath.section / sectionsPerScholarship]
		let scholarshipSection = indexPath.section % sectionsPerScholarship
		
		switch scholarshipSection {
		case 0:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.placeholder = "scholarship name"
				tfCell.prompt = "Name"
				tfCell.textField.text = scholarship.name
				tfCell.textField.keyboardType = .default
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 1:
			if indexPath.row == 0 {
				let cell = tableView.dequeueReusableCell(withIdentifier: "dateentry", for: indexPath)
				if let dfCell = cell as? DateFieldCell {
					dfCell.dateField.addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
					dfCell.setDate(scholarship.applicationDate)
					dfCell.prompt = "Date"
				}
				return cell
			} else {
				let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
				if let tfCell = cell as? TextFieldCell {
					tfCell.textField.placeholder = "website URL"
					tfCell.prompt = "Website"
					tfCell.textField.text = scholarship.website
					tfCell.textField.keyboardType = .URL
					tfCell.textField.inputAccessoryView = keyboardAccessoryView
					tfCell.textField.delegate = self
				}
				return cell
			}
		case 2:
			if indexPath.row == 4 {
				let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
				if let tfCell = cell as? TextFieldCell {
					tfCell.textField.placeholder = "other information"
					tfCell.prompt = "Other"
					tfCell.textField.text = scholarship.otherInfo
					tfCell.textField.keyboardType = .default
					tfCell.textField.inputAccessoryView = keyboardAccessoryView
					tfCell.textField.delegate = self
				}
				return cell
			} else if indexPath.row == 6 {
				let cell = tableView.dequeueReusableCell(withIdentifier: "button", for: indexPath)
				if let btnCell = cell as? ButtonCell {
					btnCell.button.setTitle("Remove This Scholarship", for: .normal)
					btnCell.button.addTarget(self, action: #selector(removeScholarship(_:)), for: .touchUpInside)
				}
				return cell
			} else {
				let cell = tableView.dequeueReusableCell(withIdentifier: "checkbox", for: indexPath)
				if let cbCell = cell as? CheckboxCell {
					switch indexPath.row {
					case 0:
						cbCell.title = "Essay or personal statement"
						cbCell.checked = scholarship.essayDone
					case 1:
						cbCell.title = "Letter(s) of recommendation"
						cbCell.checked = scholarship.recommendationsDone
					case 2:
						cbCell.title = "Activities chart or resume"
						cbCell.checked = scholarship.activitiesChartDone
					case 3:
						cbCell.title = "SAT or ACT"
						cbCell.checked = scholarship.testsDone
					case 5:
						cbCell.title = "I applied!"
						cbCell.checked = scholarship.applicationDone
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
			var scholarship = MyPlanManager.shared.scholarships[indexPath.section / sectionsPerScholarship]
			
			switch indexPath.row {
			case 0:
				scholarship.essayDone = !scholarship.essayDone
				cbCell.checked = scholarship.essayDone
			case 1:
				scholarship.recommendationsDone = !scholarship.recommendationsDone
				cbCell.checked = scholarship.recommendationsDone
			case 2:
				scholarship.activitiesChartDone = !scholarship.activitiesChartDone
				cbCell.checked = scholarship.activitiesChartDone
			case 3:
				scholarship.testsDone = !scholarship.testsDone
				cbCell.checked = scholarship.testsDone
			case 5:
				scholarship.applicationDone = !scholarship.applicationDone
				cbCell.checked = scholarship.applicationDone
			default:
				break
			}
			
			MyPlanManager.shared.scholarships[indexPath.section / sectionsPerScholarship] = scholarship
		}
	}
}
