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
	
	private var keyboardAccessoryView: UIView!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

		createKeyboardAccessoryView()
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 50
		
//		let isSetup = UserDefaults.standard.bool(forKey: "initialsecuresetup")
		
		pinPadView.layer.cornerRadius = 6.0
		pinPadView.layer.borderWidth = 0.5
		pinPadView.layer.borderColor = UIColor.gray.cgColor
		pinPadView.alpha = 0.0
		setPINButton.alpha = 0.0
		badPINLabel.alpha = 0.0
		pinTextField.delegate = self
		pinTextField.inputAccessoryView = keyboardAccessoryView
		NotificationCenter.default.addObserver(self, selector: #selector(checkPIN), name: Notification.Name.UITextFieldTextDidChange, object: pinTextField)
		
		let lockButton = UIBarButtonItem(title: "Unlock", style: .plain, target: self, action: #selector(toggleLock(_:)))
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
		
		if UserDefaults.standard.bool(forKey: "initialsecuresetup") == false {
			
			// clear all leftover values
			for key in tagFieldMap.values {
				KeychainWrapper.standard.removeObject(forKey: key)
			}
			KeychainWrapper.standard.removeObject(forKey: "pin")
			
			
			let haveBiometrics = LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
			
			var message: String? = nil
			if haveBiometrics {
				message = NSLocalizedString("You can either use your fingerprint or setup a PIN for accessing your passwords.", comment: "secure info fingerprint or PIN message")
			} else {
				message = NSLocalizedString("You need to setup a PIN for accessing your passwords.", comment: "secure info PIN message")
			}
			
			let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: NSLocalizedString("Setup PIN", comment: "Setup PIN button title"), style: .default, handler: { (action) in
				self.promptForPIN()
			}))
			if haveBiometrics {
				alertController.addAction(UIAlertAction(title: NSLocalizedString("Use Fingerprint", comment: "Use Fingerprint button title"), style: .default, handler: { (action) in
					UserDefaults.standard.set(true, forKey: "initialsecuresetup")
					UserDefaults.standard.set(true, forKey: "securewithfingerprint")
				}))
			}
			
			present(alertController, animated: true, completion: nil)
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		view.endEditing(true)
		lockInfo()
		
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	private dynamic func keyboardDidShow(_ notification: Notification) {
		
		guard let userInfo = notification.userInfo, let r = userInfo[UIKeyboardFrameEndUserInfoKey] else {
			return
		}
		
		let kbHeight = (r as AnyObject).cgRectValue.size.height
		tableViewBottomConstraint.constant = kbHeight - 40.0	// allow for tab bar height
	}
	
	private dynamic func keyboardDidHide(_ notification: Notification) {
		
		tableViewBottomConstraint.constant = 0.0
	}
	
	private func promptForPIN() {
		
		if pinPadView.alpha == 1.0 {
			return
		}
		
		pinTextField.text = ""
		setPINButton.alpha = 0.0
		badPINLabel.alpha = 0.0
		
		cancelPINButton.alpha = UserDefaults.standard.bool(forKey: "initialsecuresetup") ? 1.0 : 0.0
		
		UIView.animate(withDuration: 0.3, animations: { 
			self.pinPadView.alpha = 1.0
		}) { (complete) in
			self.pinTextField.becomeFirstResponder()
		}
	}
	
	dynamic func checkPIN() {
		
		guard let pin = pinTextField.text else {
			return
		}
		
		if UserDefaults.standard.bool(forKey: "initialsecuresetup") == false {
			setPINButton.alpha = pin.characters.count == 4 ? 1.0 : 0.0
		} else {
			
			if pin.characters.count < 4 {
				
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
		
		if let pin = pinTextField.text, pin.characters.count == 4 {
			KeychainWrapper.standard.set(pin, forKey: "pin")
			UserDefaults.standard.set(true, forKey: "initialsecuresetup")
			
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
	}
	
	@IBAction func toggleLock(_ sender: UIButton) {
		
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
	
	private dynamic func lockInfo() {
		
		for cell in tableView.visibleCells {
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.isSecureTextEntry = true
				tfCell.textField.isEnabled = false
			}
		}
		
		let lockButton = UIBarButtonItem(title: NSLocalizedString("Unlock", comment: "unlock button title"), style: .plain, target: self, action: #selector(toggleLock(_:)))
		self.navigationItem.setRightBarButton(lockButton, animated: false)
		
		locked = true
	}
	
	private dynamic func unlockInfo() {

		locked = false
		
		for cell in tableView.visibleCells {
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.isSecureTextEntry = false
				tfCell.textField.isEnabled = true
			}
		}
		
		let lockButton = UIBarButtonItem(title: NSLocalizedString("Lock", comment: "lock button title"), style: .plain, target: self, action: #selector(toggleLock(_:)))
		self.navigationItem.setRightBarButton(lockButton, animated: false)
	}
	
	public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		if textField == pinTextField {
			
			if let fieldText = textField.text {
				let length = fieldText.characters.count + string.characters.count
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
			
			let good = (ssn != nil ? ssn!.characters.count == 9 : false)
			
			if good {
				
				// format the SSN with hyphens
				ssn!.insert("-", at: ssn!.index(ssn!.startIndex, offsetBy: 3))
				ssn!.insert("-", at: ssn!.index(ssn!.startIndex, offsetBy: 6))
				textField.text = ssn
				
			} else {
				goodToSave = false
				
				// give guidance
				let message = NSLocalizedString("Social security numbers have nine numbers.", comment: "SSN hint")
				let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
				alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
				self.present(alertController, animated: true, completion: nil)
			}
		}
		
		if goodToSave {
			setInformation(textField.text, forFieldWithTag: textField.tag)
		}
	}
	
	private dynamic func doneWithKeyboard(btn: UIButton) {
		
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
		doneBtn.addTarget(self, action: #selector(doneWithKeyboard(btn:)), for: .touchUpInside)
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
	
	private let tagFieldMap = [1000: "mySSN", 1001: "parent1SSN", 1002: "parent2SSN"]
	
	private func isSSNTag(_ tag: Int) -> Bool {
		return tag == 1000 || tag == 1001 || tag == 1002
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
		return 5
	}
	
	private let bgColor = UIColor(red: 0.9893, green: 0.4250, blue: 0.0748, alpha: 0.5)
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		switch indexPath.row {
		case 0:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "The information that you enter in this section will be securely stored on your phone. It will not be shared with anyone or any organization."
				labelCell.contentView.backgroundColor = nil
				labelCell.labelTextColor = nil
			}
			return cell
		case 1:
			let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
			if let labelCell = cell as? LabelCell {
				labelCell.labelText = "Enter your Social Security number. And the numbers for your parent/gaurdians."
				labelCell.contentView.backgroundColor = bgColor
				labelCell.labelTextColor = .white
			}
			return cell
		case 2:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.tag = 1000
				tfCell.textField.placeholder = "my SSN"
				tfCell.prompt = "Mine"
				tfCell.textField.text = informationForField(withTag: tfCell.textField.tag)
				tfCell.textField.isSecureTextEntry = locked
				tfCell.textField.isEnabled = !locked
				tfCell.textField.keyboardType = .numberPad
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 3:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.tag = 1001
				tfCell.textField.placeholder = "parent/guardian SSN"
				tfCell.prompt = "Parent 1"
				tfCell.textField.text = informationForField(withTag: tfCell.textField.tag)
				tfCell.textField.isSecureTextEntry = locked
				tfCell.textField.isEnabled = !locked
				tfCell.textField.keyboardType = .numberPad
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		case 4:
			let cell = tableView.dequeueReusableCell(withIdentifier: "textentry", for: indexPath)
			if let tfCell = cell as? TextFieldCell {
				tfCell.textField.tag = 1002
				tfCell.textField.placeholder = "parent/guardian SSN"
				tfCell.prompt = "Parent 2"
				tfCell.textField.text = informationForField(withTag: tfCell.textField.tag)
				tfCell.textField.isSecureTextEntry = locked
				tfCell.textField.isEnabled = !locked
				tfCell.textField.keyboardType = .numberPad
				tfCell.textField.inputAccessoryView = keyboardAccessoryView
				tfCell.textField.delegate = self
			}
			return cell
		default:
			fatalError()
		}
	}

}
