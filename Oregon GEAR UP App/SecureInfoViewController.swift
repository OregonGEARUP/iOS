//
//  SecureInfoViewController.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 4/11/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import UIKit
import LocalAuthentication


class SecureInfoViewController: UIViewController, UITextFieldDelegate {
	
	private var locked = true

	@IBOutlet weak var ssnTextField: UITextField!
	@IBOutlet weak var lockButton: UIButton!
	
	private var keyboardAccessoryView: UIView!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

		createKeyboardAccessoryView()
		
		ssnTextField.delegate = self
		ssnTextField.inputAccessoryView = keyboardAccessoryView
		ssnTextField.text = KeychainWrapper.standard.string(forKey: "ssn")
		
		NotificationCenter.default.addObserver(self, selector: #selector(lockInfo), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if let ssn = ssnTextField.text, !ssn.isEmpty {
			lockInfo()
		} else {
			unlockInfo()
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		lockInfo()
	}
	
	@IBAction func toggleLock(_ sender: UIButton) {
		
		if locked {
			var error: NSError?
			let context = LAContext()
			if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
				
				let reason = NSLocalizedString("Unlock your secure information.", comment: "biometrics unlock reason")
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
				// no Touch ID case here
				
				self.unlockInfo()		// TEMPORARY
			}
		} else {
			lockInfo()
		}
	}
	
	private dynamic func lockInfo() {
		
		ssnTextField.isSecureTextEntry = true
		ssnTextField.isEnabled = false
		
		if let ssn = ssnTextField.text {
			KeychainWrapper.standard.set(ssn, forKey: "ssn")
		} else {
			KeychainWrapper.standard.removeObject(forKey: "ssn")
		}
		
		lockButton.setTitle(NSLocalizedString("Unlock Info", comment: "unlock button title"), for: .normal)
		
		locked = true
	}
	
	private dynamic func unlockInfo() {

		locked = false
		ssnTextField.isSecureTextEntry = false
		ssnTextField.isEnabled = true
		
		lockButton.setTitle(NSLocalizedString("Lock Info", comment: "lock button title"), for: .normal)
	}
	
	public func textFieldDidEndEditing(_ textField: UITextField) {
		
		if textField == ssnTextField {
			
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
				
				// give guidance
				let message = NSLocalizedString("Social security numbers have nine numbers.", comment: "SSN hint")
				let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
				alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
				self.present(alertController, animated: true, completion: nil)
			}
		}
	}
	
	private dynamic func doneWithKeyboard(btn: UIButton) {
		
		self.view.endEditing(true)
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
	
}
