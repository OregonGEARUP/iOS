//
//  SecureInfoViewController.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 4/11/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import UIKit
import LocalAuthentication


class SecureInfoViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
	
	private var locked = true
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet var tableViewBottomConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var pinPadView: UIView!
	@IBOutlet weak var pinTextField: UITextField!
	@IBOutlet weak var setPINButton: UIButton!
	@IBOutlet weak var cancelPINButton: UIButton!
	@IBOutlet weak var badPINLabel: UILabel!
	
	private var tagToEditAfterUnlock = -1
	
	private var keyboardAccessoryView: UIView!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

		createKeyboardAccessoryView()
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 50
		
		// clear all leftover values
		let isSetup = hasSecureSetup()
		if !isSetup {
			
			for key in tagFieldMap.values {
				KeychainWrapper.standard.removeObject(forKey: key)
			}
			KeychainWrapper.standard.removeObject(forKey: "pin")
		}
		
		pinPadView.layer.cornerRadius = 6.0
		pinPadView.layer.borderWidth = 0.5
		pinPadView.layer.borderColor = UIColor.gray.cgColor
		pinPadView.alpha = 0.0
		setPINButton.alpha = 0.0
		badPINLabel.alpha = 0.0
		pinTextField.delegate = self
		pinTextField.inputAccessoryView = keyboardAccessoryView
		NotificationCenter.default.addObserver(self, selector: #selector(checkPIN), name: Notification.Name.UITextFieldTextDidChange, object: pinTextField)
		
		let lockButton = UIBarButtonItem(title: "Unlock", style: .plain, target: self, action: #selector(toggleLock))
		self.navigationItem.setRightBarButton(lockButton, animated: false)
		
		NotificationCenter.default.addObserver(self, selector: #selector(lockInfo), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		var haveSecureInfo = false
		for tag in tagFieldMap.keys {
			if let info = informationForField(withTag: tag), !info.isEmpty {
				haveSecureInfo = true
				break
			}
		}
		for college in MyPlanManager.shared.colleges {
			if let un = college.username, !un.isEmpty {
				haveSecureInfo = true
				break
			}
			if let pw = college.username, !pw.isEmpty {
				haveSecureInfo = true
				break
			}
		}
		
		tableView.reloadData()
		
		if haveSecureInfo {
			lockInfo()
		} else {
			unlockInfo()
		}
		
		NotificationCenter.default.addObserver(self, selector:#selector(keyboardDidShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector:#selector(keyboardDidHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		checkForSecureSetup()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		view.endEditing(true)
		lockInfo()
		
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	@objc private func keyboardDidShow(_ notification: Notification) {
		
		guard let userInfo = notification.userInfo, let r = userInfo[UIKeyboardFrameEndUserInfoKey] else {
			return
		}
		
		let kbHeight = (r as AnyObject).cgRectValue.size.height
		tableViewBottomConstraint.constant = kbHeight - 40.0	// allow for tab bar height
	}
	
	@objc private func keyboardDidHide(_ notification: Notification) {
		
		tableViewBottomConstraint.constant = 0.0
	}
	
	private func hasSecureSetup() -> Bool {
		
		let needsAndHasBiometrics = UserDefaults.standard.bool(forKey: "securewithfingerprint") == false || LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
		return UserDefaults.standard.bool(forKey: "initialsecuresetup") && needsAndHasBiometrics
	}
	
	private func checkForSecureSetup() {
		
		if hasSecureSetup() == false {
			
			let haveBiometrics = LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
			var haveFaceID = false
			if #available(iOS 11.0, *), LAContext().biometryType == .faceID {
				haveFaceID = true
			}
			
			var message: String? = nil
			if haveBiometrics {
				if haveFaceID {
					message = NSLocalizedString("You can either use Face ID or setup a PIN for accessing your passwords.", comment: "secure info Face ID or PIN message")
				} else {
					message = NSLocalizedString("You can either use Touch ID or setup a PIN for accessing your passwords.", comment: "secure info Touch ID or PIN message")
				}
			} else {
				message = NSLocalizedString("You need to setup a PIN for accessing your passwords.", comment: "secure info PIN message")
			}
			
			let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: NSLocalizedString("Setup PIN", comment: "Setup PIN button title"), style: .default, handler: { (action) in
				self.promptForPIN()
			}))
			if haveBiometrics {
				let title = haveFaceID ? NSLocalizedString("Use Face ID", comment: "Use Face ID button title") : NSLocalizedString("Use Touch ID", comment: "Use Touch ID button title")
				alertController.addAction(UIAlertAction(title: title, style: .default, handler: { (action) in
					UserDefaults.standard.set(true, forKey: "initialsecuresetup")
					UserDefaults.standard.set(true, forKey: "securewithfingerprint")
				}))
			}
			
			present(alertController, animated: true, completion: nil)
		}
	}
	
	private func promptForPIN() {
		
		if pinPadView.alpha == 1.0 {
			return
		}
		
		pinTextField.text = ""
		setPINButton.alpha = 0.0
		badPINLabel.alpha = 0.0
		
		cancelPINButton.alpha = hasSecureSetup() ? 1.0 : 0.0
		
		UIView.animate(withDuration: 0.3, animations: { 
			self.pinPadView.alpha = 1.0
		}) { (complete) in
			self.pinTextField.becomeFirstResponder()
		}
	}
	
	@objc private func checkPIN() {
		
		guard let pin = pinTextField.text else {
			return
		}
		
		if hasSecureSetup() == false {
			setPINButton.alpha = pin.count == 4 ? 1.0 : 0.0
		} else {
			
			if pin.count < 4 {
				
				UIView.animate(withDuration: 0.2, animations: {
					self.badPINLabel.alpha = 0.0
				})
				return
			}
			
			let goodpin = KeychainWrapper.standard.string(forKey: "pin")
			if pin == goodpin {
				
				pinTextField.resignFirstResponder()
				
				UIView.animate(withDuration: 0.3, animations: { 
					self.pinPadView.alpha = 0.0
				}, completion: { (complete) in
					self.unlockInfo()
				})
				
				return
			}
			
			// pin does not match
			UIView.animate(withDuration: 0.2, animations: { 
				self.badPINLabel.alpha = 1.0
			})
		}
	}
	
	@IBAction func setPIN() {
		
		if let pin = pinTextField.text, pin.count == 4 {
			KeychainWrapper.standard.set(pin, forKey: "pin")
			UserDefaults.standard.set(true, forKey: "initialsecuresetup")
			UserDefaults.standard.set(false, forKey: "securewithfingerprint")

			pinTextField.resignFirstResponder()
			
			UIView.animate(withDuration: 0.3, animations: { 
				self.pinPadView.alpha = 0.0
			})
		}
	}
	
	@IBAction func cancelPIN() {
		
		pinTextField.resignFirstResponder()
		
		UIView.animate(withDuration: 0.3, animations: {
			self.pinPadView.alpha = 0.0
		})
		
		tagToEditAfterUnlock = -1
	}
	
	@IBAction func toggleLock() {
		
		// make sure we have a PIN established
		if !hasSecureSetup() {
			checkForSecureSetup()
			return
		}

		if locked {
			var error: NSError?
			let context = LAContext()
			if UserDefaults.standard.bool(forKey: "securewithfingerprint") && context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
				
				let reason = NSLocalizedString("Unlock your passwords.", comment: "biometrics unlock reason")
				context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
					[unowned self] (success, authenticationError) in
					
					DispatchQueue.main.async {
						if success {
							self.unlockInfo()
						} else {
							if let error = authenticationError {
								print(error)
							}
							
							self.tagToEditAfterUnlock = -1
						}
					}
				}
			} else {
				// no Touch ID case
				self.promptForPIN()
			}
		} else {
			lockInfo()
		}
	}
	
	@objc private func lockInfo() {
		
		doneWithKeyboard()
		
		for cell in tableView.visibleCells {
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.isSecureTextEntry = true
				//tfCell.textField.isEnabled = false
			}
		}
		
		let lockButton = UIBarButtonItem(title: NSLocalizedString("Unlock", comment: "unlock button title"), style: .plain, target: self, action: #selector(toggleLock))
		self.navigationItem.setRightBarButton(lockButton, animated: false)
		
		locked = true
	}
	
	@objc private func unlockInfo() {

		locked = false
		
		for cell in tableView.visibleCells {
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.isSecureTextEntry = false
				tfCell.textField.isEnabled = true
			}
		}
		
		let lockButton = UIBarButtonItem(title: NSLocalizedString("Lock", comment: "lock button title"), style: .plain, target: self, action: #selector(toggleLock))
		self.navigationItem.setRightBarButton(lockButton, animated: false)
		
		if tagToEditAfterUnlock >= 0 {
			
			let tagToEdit = tagToEditAfterUnlock
			tagToEditAfterUnlock = -1
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
				
				if let tfCell = self.tableView.cellForRow(at: IndexPath(row: tagToEdit, section: 0)) as? TextFieldCell {
					tfCell.textField.becomeFirstResponder()
				}
			}
		}
	}
	
	public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		
		if textField == pinTextField {
			return true
		}
		
		// make sure we have a PIN established
		if !hasSecureSetup() {
			checkForSecureSetup()
			return false
		}
		
		// prompt to unlock
		if locked {
			tagToEditAfterUnlock = textField.tag
			toggleLock()
			return false
		}
		
		return true
	}
	
	public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		if textField == pinTextField {
			
			if let fieldText = textField.text {
				let length = fieldText.count + string.count
				return length <= 4
			}
			
			return false
		}
		
		return true
	}
	
	public func textFieldDidEndEditing(_ textField: UITextField) {
		
		if textField == pinTextField {
			return
		}
		
		
		var goodToSave = true
		if isSSNTag(textField.tag) {
			
			var ssn = textField.text
			if ssn != nil {
				ssn = ssn!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
			}
			
			let good = (ssn != nil ? ssn!.count == 9 : false)
			
			if good {
				
				// format the SSN with hyphens
				ssn!.insert("-", at: ssn!.index(ssn!.startIndex, offsetBy: 3))
				ssn!.insert("-", at: ssn!.index(ssn!.startIndex, offsetBy: 6))
				textField.text = ssn
				
			} else {
				goodToSave = false
				
				// give guidance for bad SSN
				if let ssn = ssn, !ssn.isEmpty {
					let message = NSLocalizedString("Social security numbers have nine numbers.", comment: "SSN hint")
					let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
					alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
					self.present(alertController, animated: true, completion: nil)
				}
			}
		}
		
		if goodToSave {
			
			if textField.tag <= maxFixedFieldsTag {
				setInformation(textField.text, forFieldWithTag: textField.tag)
			} else {
				
				// college username/password cases
				let collegeIndex = (textField.tag - maxFixedFieldsTag) / 3
				let collegeRow = (textField.tag - maxFixedFieldsTag) % 3
				switch collegeRow {
				case 1:	MyPlanManager.shared.colleges[collegeIndex].username = textField.text
				case 2:	MyPlanManager.shared.colleges[collegeIndex].password = textField.text
				default: break
				}
				
			}
		}
	}
	
	@objc private func doneWithKeyboard() {
		
		view.endEditing(true)
		
		if setPINButton.alpha == 1.0 {
			setPIN()
		}
		
		if pinPadView.alpha == 1.0 {
			UIView.animate(withDuration: 0.3, animations: {
				self.pinPadView.alpha = 0.0
			})
		}
	}
	
	private func createKeyboardAccessoryView() {
		
		// add a done button for the keyboard
		keyboardAccessoryView = UIView(frame: CGRect(x:0.0, y:0.0, width:0.0, height:40.0))
		keyboardAccessoryView.backgroundColor = UIColor(red: 0.7790, green: 0.7963, blue: 0.8216, alpha: 0.9)
		
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
		doneBtn.addTarget(self, action: #selector(doneWithKeyboard), for: .touchUpInside)
		keyboardAccessoryView.addSubview(doneBtn)
		
		NSLayoutConstraint.activate([
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
	
	private let tagFieldMap = [3: "mySSN", 4: "parent1SSN", 5: "parent2SSN", 7: "driverlicense",
	                           9: "fsaUsername", 10: "fsaPassword", 12: "ORSAAusername", 13: "ORSAApassword", 15: "CSSusername", 16: "CSSpassword",
	                           18: "extra1Org", 19: "extra1Username", 20: "extra1Password", 22: "extra2Org", 23: "extra2Username", 24: "extra2Password",
	                           27: "emailUsername", 28: "emailPassword", 30: "OSACusername", 31: "OSACpassword"]
	
	private let maxFixedFieldsTag = 31
	
	private func isSSNTag(_ tag: Int) -> Bool {
		return tag == 3 || tag == 4 || tag == 5
	}
	
	private func informationForField(withTag tag: Int) -> String? {
		
		if let key = tagFieldMap[tag] {
			return KeychainWrapper.standard.string(forKey: key)
		}
		
		return nil
	}
	
	private func setInformation(_ info: String?, forFieldWithTag tag: Int) {
		
		if let key = tagFieldMap[tag] {
			if let info = info {
				KeychainWrapper.standard.set(info, forKey: key)
			} else {
				KeychainWrapper.standard.removeObject(forKey: key)
			}
		}
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return maxFixedFieldsTag + 1 + MyPlanManager.shared.colleges.count * 3
	}
	
	private let headerBgColor = StyleGuide.myPlanColor
	private let headerTextColor = UIColor.white
	private let subheadBgColor = StyleGuide.myPlanColor.withAlphaComponent(0.1)
	private let subheadTextColor = UIColor.lightGray
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		switch indexPath.row {
		case 0:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "Store usernames and passwords securely on your phone; this information will not be shared."
				labelCell.contentView.backgroundColor = nil
				labelCell.labelTextColor = .gray
				labelCell.labelFontItalicSize = 17.0
			}
			return cell
		case 1:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "Financial Aid Information"
				labelCell.contentView.backgroundColor = headerBgColor
				labelCell.labelTextColor = headerTextColor
				labelCell.labelFontSize = 17.0
			}
			return cell
		case 2:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "Enter your and your parent/gaurdian(s) Social Security numbers (SSN)."
				labelCell.contentView.backgroundColor = subheadBgColor
				labelCell.labelTextColor = subheadTextColor
				labelCell.labelFontSize = 17.0
			}
			return cell
		case 3:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.tag = 3
				tfCell.textField.placeholder = "my SSN"
				tfCell.prompt = "My SSN"
				tfCell.textField.keyboardType = .numberPad
				tfCell.textField.text = informationForField(withTag: tfCell.textField.tag)
				tfCell.textField.isSecureTextEntry = locked
				tfCell.textField.isEnabled = true
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 4:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.tag = 4
				tfCell.textField.placeholder = "parent/guardian SSN"
				tfCell.prompt = "Parent/Guardian #1 SSN"
				tfCell.textField.keyboardType = .numberPad
				tfCell.textField.text = informationForField(withTag: tfCell.textField.tag)
				tfCell.textField.isSecureTextEntry = locked
				tfCell.textField.isEnabled = true
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 5:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.tag = 5
				tfCell.textField.placeholder = "parent/guardian SSN"
				tfCell.prompt = "Parent/Guardian #2 SSN"
				tfCell.textField.keyboardType = .numberPad
				tfCell.textField.text = informationForField(withTag: tfCell.textField.tag)
				tfCell.textField.isSecureTextEntry = locked
				tfCell.textField.isEnabled = true
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 6:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "Enter your driver license number."
				labelCell.contentView.backgroundColor = subheadBgColor
				labelCell.labelTextColor = subheadTextColor
				labelCell.labelFontSize = 17.0
			}
			return cell
		case 7:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.tag = 7
				tfCell.textField.placeholder = "driver license number"
				tfCell.prompt = "Driver License Number"
				tfCell.textField.keyboardType = .numbersAndPunctuation
				tfCell.textField.autocorrectionType = .no
				tfCell.textField.spellCheckingType = .no
				tfCell.textField.text = informationForField(withTag: tfCell.textField.tag)
				tfCell.textField.isSecureTextEntry = locked
				tfCell.textField.isEnabled = true
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 8:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "FSA ID"
				labelCell.contentView.backgroundColor = subheadBgColor
				labelCell.labelTextColor = subheadTextColor
				labelCell.labelFontSize = 17.0
			}
			return cell
		case 9:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.tag = 9
				tfCell.textField.placeholder = "FSA username"
				tfCell.prompt = "Username"
				tfCell.textField.keyboardType = .default
				tfCell.textField.autocorrectionType = .no
				tfCell.textField.spellCheckingType = .no
				tfCell.textField.text = informationForField(withTag: tfCell.textField.tag)
				tfCell.textField.isSecureTextEntry = locked
				tfCell.textField.isEnabled = true
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 10:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.tag = 10
				tfCell.textField.placeholder = "FSA password"
				tfCell.prompt = "Password"
				tfCell.textField.keyboardType = .default
				tfCell.textField.autocorrectionType = .no
				tfCell.textField.spellCheckingType = .no
				tfCell.textField.text = informationForField(withTag: tfCell.textField.tag)
				tfCell.textField.isSecureTextEntry = locked
				tfCell.textField.isEnabled = true
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 11:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "ORSAA"
				labelCell.contentView.backgroundColor = subheadBgColor
				labelCell.labelTextColor = subheadTextColor
				labelCell.labelFontSize = 17.0
			}
			return cell
		case 12:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.tag = 12
				tfCell.textField.placeholder = "ORSAA username"
				tfCell.prompt = "Username"
				tfCell.textField.keyboardType = .default
				tfCell.textField.autocorrectionType = .no
				tfCell.textField.spellCheckingType = .no
				tfCell.textField.text = informationForField(withTag: tfCell.textField.tag)
				tfCell.textField.isSecureTextEntry = locked
				tfCell.textField.isEnabled = true
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 13:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.tag = 13
				tfCell.textField.placeholder = "ORSAA password"
				tfCell.prompt = "Password"
				tfCell.textField.keyboardType = .default
				tfCell.textField.autocorrectionType = .no
				tfCell.textField.spellCheckingType = .no
				tfCell.textField.text = informationForField(withTag: tfCell.textField.tag)
				tfCell.textField.isSecureTextEntry = locked
				tfCell.textField.isEnabled = true
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 14:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "CSS Profile"
				labelCell.contentView.backgroundColor = subheadBgColor
				labelCell.labelTextColor = subheadTextColor
				labelCell.labelFontSize = 17.0
			}
			return cell
		case 15:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.tag = 15
				tfCell.textField.placeholder = "CSS username"
				tfCell.prompt = "Username"
				tfCell.textField.keyboardType = .default
				tfCell.textField.autocorrectionType = .no
				tfCell.textField.spellCheckingType = .no
				tfCell.textField.text = informationForField(withTag: tfCell.textField.tag)
				tfCell.textField.isSecureTextEntry = locked
				tfCell.textField.isEnabled = true
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 16:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.tag = 16
				tfCell.textField.placeholder = "CSS password"
				tfCell.prompt = "Password"
				tfCell.textField.keyboardType = .default
				tfCell.textField.autocorrectionType = .no
				tfCell.textField.spellCheckingType = .no
				tfCell.textField.text = informationForField(withTag: tfCell.textField.tag)
				tfCell.textField.isSecureTextEntry = locked
				tfCell.textField.isEnabled = true
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
			
		case 17:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "Extra Login #1"
				labelCell.contentView.backgroundColor = subheadBgColor
				labelCell.labelTextColor = subheadTextColor
				labelCell.labelFontSize = 17.0
			}
			return cell
		case 18:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.tag = 18
				tfCell.textField.placeholder = "Organization"
				tfCell.prompt = "Organization"
				tfCell.textField.keyboardType = .default
				tfCell.textField.autocorrectionType = .no
				tfCell.textField.spellCheckingType = .no
				tfCell.textField.text = informationForField(withTag: tfCell.textField.tag)
				tfCell.textField.isSecureTextEntry = locked
				tfCell.textField.isEnabled = true
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 19:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.tag = 19
				tfCell.textField.placeholder = "Username"
				tfCell.prompt = "Username"
				tfCell.textField.keyboardType = .default
				tfCell.textField.autocorrectionType = .no
				tfCell.textField.spellCheckingType = .no
				tfCell.textField.text = informationForField(withTag: tfCell.textField.tag)
				tfCell.textField.isSecureTextEntry = locked
				tfCell.textField.isEnabled = true
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 20:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.tag = 20
				tfCell.textField.placeholder = "Password"
				tfCell.prompt = "Password"
				tfCell.textField.keyboardType = .default
				tfCell.textField.autocorrectionType = .no
				tfCell.textField.spellCheckingType = .no
				tfCell.textField.text = informationForField(withTag: tfCell.textField.tag)
				tfCell.textField.isSecureTextEntry = locked
				tfCell.textField.isEnabled = true
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
			
			
		case 21:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "Extra Login #2"
				labelCell.contentView.backgroundColor = subheadBgColor
				labelCell.labelTextColor = subheadTextColor
				labelCell.labelFontSize = 17.0
			}
			return cell
		case 22:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.tag = 22
				tfCell.textField.placeholder = "Organization"
				tfCell.prompt = "Organization"
				tfCell.textField.keyboardType = .default
				tfCell.textField.autocorrectionType = .no
				tfCell.textField.spellCheckingType = .no
				tfCell.textField.text = informationForField(withTag: tfCell.textField.tag)
				tfCell.textField.isSecureTextEntry = locked
				tfCell.textField.isEnabled = true
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 23:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.tag = 23
				tfCell.textField.placeholder = "Username"
				tfCell.prompt = "Username"
				tfCell.textField.keyboardType = .default
				tfCell.textField.autocorrectionType = .no
				tfCell.textField.spellCheckingType = .no
				tfCell.textField.text = informationForField(withTag: tfCell.textField.tag)
				tfCell.textField.isSecureTextEntry = locked
				tfCell.textField.isEnabled = true
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 24:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.tag = 24
				tfCell.textField.placeholder = "Password"
				tfCell.prompt = "Password"
				tfCell.textField.keyboardType = .default
				tfCell.textField.autocorrectionType = .no
				tfCell.textField.spellCheckingType = .no
				tfCell.textField.text = informationForField(withTag: tfCell.textField.tag)
				tfCell.textField.isSecureTextEntry = locked
				tfCell.textField.isEnabled = true
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
			
			
		case 25:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "College and Scholarship Applications"
				labelCell.contentView.backgroundColor = headerBgColor
				labelCell.labelTextColor = headerTextColor
				labelCell.labelFontSize = 17.0
			}
			return cell
		case 26:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "The email address and password you will use for applications."
				labelCell.contentView.backgroundColor = subheadBgColor
				labelCell.labelTextColor = subheadTextColor
				labelCell.labelFontSize = 17.0
			}
			return cell
		case 27:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.tag = 27
				tfCell.textField.placeholder = "email username"
				tfCell.prompt = "Email"
				tfCell.textField.keyboardType = .emailAddress
				tfCell.textField.autocorrectionType = .no
				tfCell.textField.spellCheckingType = .no
				tfCell.textField.text = informationForField(withTag: tfCell.textField.tag)
				tfCell.textField.isSecureTextEntry = locked
				tfCell.textField.isEnabled = true
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 28:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.tag = 28
				tfCell.textField.placeholder = "email password"
				tfCell.prompt = "Password"
				tfCell.textField.keyboardType = .default
				tfCell.textField.autocorrectionType = .no
				tfCell.textField.spellCheckingType = .no
				tfCell.textField.text = informationForField(withTag: tfCell.textField.tag)
				tfCell.textField.isSecureTextEntry = locked
				tfCell.textField.isEnabled = true
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 29:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "OSAC"
				labelCell.contentView.backgroundColor = subheadBgColor
				labelCell.labelTextColor = subheadTextColor
				labelCell.labelFontSize = 17.0
			}
			return cell
		case 30:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.tag = 30
				tfCell.textField.placeholder = "OSAC username"
				tfCell.prompt = "Username"
				tfCell.textField.keyboardType = .default
				tfCell.textField.autocorrectionType = .no
				tfCell.textField.spellCheckingType = .no
				tfCell.textField.text = informationForField(withTag: tfCell.textField.tag)
				tfCell.textField.isSecureTextEntry = locked
				tfCell.textField.isEnabled = true
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 31:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.tag = 31
				tfCell.textField.placeholder = "OSAC password"
				tfCell.prompt = "Password"
				tfCell.textField.keyboardType = .default
				tfCell.textField.autocorrectionType = .no
				tfCell.textField.spellCheckingType = .no
				tfCell.textField.text = informationForField(withTag: tfCell.textField.tag)
				tfCell.textField.isSecureTextEntry = locked
				tfCell.textField.isEnabled = true
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
			
		default:
			let collegeIndex = (indexPath.row - (maxFixedFieldsTag+1)) / 3
			let college = MyPlanManager.shared.colleges[collegeIndex]
			
			let collegeRow = (indexPath.row - (maxFixedFieldsTag+1)) % 3
			switch collegeRow {
			case 0:
				let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
				if let labelCell = cell as? LabelCell {
					labelCell.labelText = college.name
					labelCell.contentView.backgroundColor = subheadBgColor
					labelCell.labelTextColor = subheadTextColor
					labelCell.labelFontSize = 17.0
				}
				return cell
			case 1:
				let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
				if let tfCell = cell as? TextFieldCell {
					tfCell.textField.tag = indexPath.row
					tfCell.textField.placeholder = "college website username"
					tfCell.prompt = "Username"
					tfCell.textField.keyboardType = .default
					tfCell.textField.autocorrectionType = .no
					tfCell.textField.spellCheckingType = .no
					tfCell.textField.text = college.username
					tfCell.textField.isSecureTextEntry = locked
					tfCell.textField.isEnabled = true
					tfCell.textField.inputAccessoryView = keyboardAccessoryView
					tfCell.textField.delegate = self
				}
				return cell
			case 2:
				let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
				if let tfCell = cell as? TextFieldCell {
					tfCell.textField.tag = indexPath.row
					tfCell.textField.placeholder = "college website password"
					tfCell.prompt = "Password"
					tfCell.textField.keyboardType = .default
					tfCell.textField.autocorrectionType = .no
					tfCell.textField.spellCheckingType = .no
					tfCell.textField.text = college.password
					tfCell.textField.isSecureTextEntry = locked
					tfCell.textField.isEnabled = true
					tfCell.textField.inputAccessoryView = keyboardAccessoryView
					tfCell.textField.delegate = self
				}
				return cell
				
			default:
				fatalError()
			}
		}
	}
}
