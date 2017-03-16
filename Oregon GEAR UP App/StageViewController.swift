//
//  StageViewController.swift
//  Oregon GEAR UP App
//
//  Created by Max MacEachern on 11/28/16.
//  Copyright © 2016 Oregon GEAR UP. All rights reserved.
//

import UIKit


class WebViewController: UIViewController {
    var url: URL?
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if let ulr = url {
			let request = URLRequest(url: ulr)
			self.webView.loadRequest(request)
		}
    }
}


class StageViewController: UIViewController {
    
    // Outlets for the UI Elements shared by all checkpoint types
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var moreInfoButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    // Field checkpoint UI Elements
    @IBOutlet weak var fieldLabel1: UILabel!
    @IBOutlet weak var inputField1: UITextField!
    @IBOutlet weak var fieldLabel2: UILabel!
    @IBOutlet weak var inputField2: UITextField!
    @IBOutlet weak var fieldLabel3: UILabel!
    @IBOutlet weak var inputField3: UITextField!
	
    // Stackview UI Elements
    @IBOutlet weak var fieldStackview: UIStackView!
    @IBOutlet weak var checkboxStackview: UIStackView!
    @IBOutlet weak var radioStackview: UIStackView!
    @IBOutlet weak var fieldDateStackview: UIStackView!
    
    // Field Date checkpoint UI elements
    @IBOutlet weak var fieldDateLabel1: UILabel!
	@IBOutlet weak var inputFieldDate1: UITextField!
    @IBOutlet weak var inputDate1: UIButton!
    @IBOutlet weak var fieldDateLabel2: UILabel!
    @IBOutlet weak var inputFieldDate2: UITextField!
    @IBOutlet weak var inputDate2: UIButton!
    @IBOutlet weak var fieldDateLabel3: UILabel!
    @IBOutlet weak var inputFieldDate3: UITextField!
    @IBOutlet weak var inputDate3: UIButton!
    @IBOutlet weak var fieldDatePicker: UIDatePicker!
	
	var currentInputDate: UIButton?
    @IBOutlet weak var pickerPaletteView: UIView!
    
    // Checkbox UI Elements
    @IBOutlet var checkboxesButtons: [UIButton]!
    
	// Radiobutton collection
	@IBOutlet var radioButtons: [UIButton]!
	
	// constraint used to move the main view to avoid the keyboard
    @IBOutlet weak var outerTopConstraint: NSLayoutConstraint!
	private var keyboardHeight: CGFloat = 0.0
	private let unadjustedOffset: CGFloat = 8.0
	
    // view used for keyboard Done button
    private var keyboardAccessoryView: UIView!
	
	var blockIndex = 0
	var stageIndex = 0
    var checkpointIndex = 0
	
    var datePaletteVisible = false
	
	
	// MARK: - View Controller Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// add hanlders for moreInfo, Next and Prev buttons
		moreInfoButton.addTarget(self, action: #selector(showMoreInfo), for: .touchUpInside)
		nextButton.addTarget(self, action: #selector(showNextCheckpoint), for: .touchUpInside)
		prevButton.addTarget(self, action: #selector(showPrevCheckpoint), for: .touchUpInside)
		
		// empty the UI until we have data to drive it
		titleLabel.text = nil
		descriptionLabel.text = nil
		moreInfoButton.setTitle(nil, for: .normal)
		fieldStackview.isHidden = true
		checkboxStackview.isHidden = true
		radioStackview.isHidden = true
		fieldDateStackview.isHidden = true
		pickerPaletteView.isHidden = true
		
		
		// add a done button for the keyboard
		keyboardAccessoryView = UIView(frame: CGRect(x:0.0, y:0.0, width:0.0, height:40.0))
		keyboardAccessoryView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.9)
		
		let prevBtn = UIButton(type: .system)
		prevBtn.translatesAutoresizingMaskIntoConstraints = false
		prevBtn.setTitle("<", for: .normal)
		prevBtn.addTarget(self, action: #selector(previousField(btn:)), for: .touchUpInside)
		keyboardAccessoryView.addSubview(prevBtn)
		
		let nextBtn = UIButton(type: .system)
		nextBtn.translatesAutoresizingMaskIntoConstraints = false
		nextBtn.setTitle(">", for: .normal)
		nextBtn.addTarget(self, action: #selector(nextField(btn:)), for: .touchUpInside)
		keyboardAccessoryView.addSubview(nextBtn)
		
		let doneBtn = UIButton(type: .system)
		doneBtn.translatesAutoresizingMaskIntoConstraints = false
		doneBtn.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
		doneBtn.addTarget(self, action: #selector(doneWithKeyboard(btn:)), for: .touchUpInside)
		keyboardAccessoryView.addSubview(doneBtn)
		
		NSLayoutConstraint.activate([
			prevBtn.topAnchor.constraint(equalTo: keyboardAccessoryView.topAnchor),
			prevBtn.bottomAnchor.constraint(equalTo: keyboardAccessoryView.bottomAnchor),
			prevBtn.leadingAnchor.constraint(equalTo: keyboardAccessoryView.leadingAnchor, constant: 20.0),
			nextBtn.topAnchor.constraint(equalTo: keyboardAccessoryView.topAnchor),
			nextBtn.bottomAnchor.constraint(equalTo: keyboardAccessoryView.bottomAnchor),
			nextBtn.leadingAnchor.constraint(equalTo: prevBtn.trailingAnchor, constant: 20.0),
			doneBtn.topAnchor.constraint(equalTo: keyboardAccessoryView.topAnchor),
			doneBtn.bottomAnchor.constraint(equalTo: keyboardAccessoryView.bottomAnchor),
			doneBtn.trailingAnchor.constraint(equalTo: keyboardAccessoryView.trailingAnchor, constant: -20.0)
		])
		
		for subview in fieldStackview.arrangedSubviews {
			if let textField = subview as? UITextField {
				textField.inputAccessoryView = keyboardAccessoryView
			}
		}
		
		for subview in fieldDateStackview.arrangedSubviews {
			if let textField = subview as? UITextField {
				textField.inputAccessoryView = keyboardAccessoryView
			}
		}
		
		inputDate1.layer.borderColor = UIColor.lightGray.cgColor
		inputDate1.layer.cornerRadius = 4.0
		inputDate1.layer.borderWidth = 0.5
		
		inputDate2.layer.borderColor = UIColor.lightGray.cgColor
		inputDate2.layer.cornerRadius = 4.0
		inputDate2.layer.borderWidth = 0.5
		
		inputDate3.layer.borderColor = UIColor.lightGray.cgColor
		inputDate3.layer.cornerRadius = 4.0
		inputDate3.layer.borderWidth = 0.5
		
		fieldDatePicker.addTarget(self, action: #selector(fieldDatePickerHandler(_:)), for: UIControlEvents.valueChanged)
		
		// TODO: handle this in the storyborad file
		let doneBtn2 = UIButton(type: .system)
		doneBtn2.translatesAutoresizingMaskIntoConstraints = false
		doneBtn2.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
		doneBtn2.addTarget(self, action: #selector(dismissDatePicker), for: .touchUpInside)
		pickerPaletteView.addSubview(doneBtn2)
		
		NSLayoutConstraint.activate([
			doneBtn2.topAnchor.constraint(equalTo: pickerPaletteView.topAnchor),
			doneBtn2.trailingAnchor.constraint(equalTo: pickerPaletteView.trailingAnchor, constant: -20.0)
		])
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// hookup the keyboard show/hide notifications
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: Notification.Name.UIKeyboardDidShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
		
		title = CheckpointManager.shared.blocks[blockIndex].stages[stageIndex].title
		
		loadCheckpoint(at: checkpointIndex)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		// unhookup the keyboard show/hide notifications
		NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardDidShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Field Date UI implementation
		pickerPaletteView.frame = CGRect(x: 0, y: self.view.bounds.size.height, width: self.view.bounds.size.width, height: pickerPaletteView.frame.size.height)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		
		// Dispose of any resources that can be recreated.
	}
	
	
	// MARK: - Checkpoint Handling
	
	private var checkpoints: [Checkpoint] {
		return CheckpointManager.shared.blocks[blockIndex].stages[stageIndex].checkpoints
	}
	
	private func keyForInstanceIndex(_ instanceIndex: Int) -> String {
		return CheckpointManager.shared.keyForBlockIndex(blockIndex, stageIndex: stageIndex, checkpointIndex: checkpointIndex, instanceIndex: instanceIndex)
	}
	
	func loadCheckpoint(at index: Int) {
		
		if index < 0 || index >= checkpoints.count {
			return
		}
		
		checkpointIndex = index
        let cp = checkpoints[checkpointIndex]
		
        // set Title, Description, & More Info
        titleLabel.text = cp.title
		
        descriptionLabel.text = cp.description
		
        if let moreInfo = cp.moreInfo {
            moreInfoButton.setTitle(moreInfo, for: .normal)
            moreInfoButton.isHidden = false
        } else {
            moreInfoButton.isHidden = true
        }
		
        
        // display checkpoint and load existing input from UserDefaults
		setupStackViews(forEntryType:cp.type)
		
		let defaults = UserDefaults.standard
		
		switch cp.type {
        case .fieldEntry:
			
			if (cp.instances.count > 0) {
				fieldLabel1.isHidden = false
				inputField1.isHidden = false
				fieldLabel1.text = cp.instances[0].prompt
				if let fieldContent = defaults.string(forKey: keyForInstanceIndex(1)) {
					inputField1.text = fieldContent
				}
			} else {
				fieldLabel1.isHidden = true
				inputField1.isHidden = true
			}
			
			if (cp.instances.count > 1) {
				fieldLabel2.isHidden = false
				inputField2.isHidden = false
				fieldLabel2.text = cp.instances[1].prompt
				if let fieldContent = defaults.string(forKey: keyForInstanceIndex(2)) {
					inputField2.text = fieldContent
				}
			} else {
				fieldLabel2.isHidden = true
				inputField2.isHidden = true
			}
			
			if (cp.instances.count > 2) {
				fieldLabel3.isHidden = false
				inputField3.isHidden = false
				fieldLabel3.text = cp.instances[2].prompt
				if let fieldContent = defaults.string(forKey: keyForInstanceIndex(3)) {
					inputField3.text = fieldContent
				}
			} else {
				fieldLabel3.isHidden = true
				inputField3.isHidden = true
			}
		
        case .checkboxEntry:
            for (index, checkbox) in checkboxesButtons.enumerated() {
				
				if (index < cp.instances.count) {
					checkbox.isHidden = false
					checkbox.setTitle(cp.instances[index].prompt, for: .normal)
					checkbox.isSelected = defaults.bool(forKey: keyForInstanceIndex(index+1))
				} else {
					checkbox.isHidden = true
				}
            }
		
        case .radioEntry:
            for (index, radio) in radioButtons.enumerated() {
				
				if (index < cp.instances.count) {
					radio.isHidden = false
					radio.setTitle(cp.instances[index].prompt, for: .normal)
					radio.isSelected = defaults.bool(forKey: keyForInstanceIndex(index+1))
				} else {
					radio.isHidden = true
				}
            }
		
        case .dateAndTextEntry:
			
			if (cp.instances.count > 0) {
				fieldDateLabel1.isHidden = false
				inputFieldDate1.isHidden = false
				inputDate1.isHidden = false
				fieldDateLabel1.text = cp.instances[0].prompt
				
				let key1 = keyForInstanceIndex(1)
				inputFieldDate1.text = defaults.string(forKey: "\(key1)_field")
				inputDate1.setTitle(defaults.string(forKey: "\(key1)_date"), for: .normal)
			} else {
				fieldDateLabel1.isHidden = true
				inputFieldDate1.isHidden = true
				inputDate1.isHidden = true
			}
			
			if (cp.instances.count > 1) {
				fieldDateLabel2.isHidden = false
				inputFieldDate2.isHidden = false
				inputDate2.isHidden = false
				fieldDateLabel2.text = cp.instances[1].prompt
				
				let key2 = keyForInstanceIndex(2)
				inputFieldDate2.text = defaults.string(forKey: "\(key2)_field")
				inputDate2.setTitle(defaults.string(forKey: "\(key2)_date"), for: .normal)
			} else {
				fieldDateLabel2.isHidden = true
				inputFieldDate2.isHidden = true
				inputDate2.isHidden = true
			}
			
			if (cp.instances.count > 2) {
				fieldDateLabel3.isHidden = false
				inputFieldDate3.isHidden = false
				inputDate3.isHidden = false
				fieldDateLabel3.text = cp.instances[2].prompt
				
				let key3 = keyForInstanceIndex(3)
				inputFieldDate3.text = defaults.string(forKey: "\(key3)_field")
				inputDate3.setTitle(defaults.string(forKey: "\(key3)_date"), for: .normal)
			} else {
				fieldDateLabel3.isHidden = true
				inputFieldDate3.isHidden = true
				inputDate3.isHidden = true
			}
			
		case .infoEntry:
			// info checkpoints just have static text
			fieldLabel1.isHidden = true
			inputField1.isHidden = true
			fieldLabel2.isHidden = true
			inputField2.isHidden = true
			fieldLabel3.isHidden = true
			inputField3.isHidden = true
			break
        }
		
		UIView.animate(withDuration: 0.3) {
			self.nextButton.alpha = (self.checkpointIndex < CheckpointManager.shared.blocks[self.blockIndex].stages[self.stageIndex].checkpoints.count - 1 ? 1.0 : 0.0)
			self.prevButton.alpha = (self.checkpointIndex > 0 ? 1.0 : 0.0)
			self.submitButton.alpha = (cp.type != .infoEntry ? 1.0 : 0.0)
		}
    }
	
	func setupStackViews(forEntryType type: EntryType) {
		fieldStackview.isHidden = (type != .fieldEntry && type != .infoEntry)
		checkboxStackview.isHidden = (type != .checkboxEntry)
		radioStackview.isHidden = (type != .radioEntry)
		fieldDateStackview.isHidden = (type != .dateAndTextEntry)
	}
	
    // next and previous checkpoint functions to navigate between checkpoints
    func showNextCheckpoint() {
        if checkpointIndex < CheckpointManager.shared.blocks[blockIndex].stages[stageIndex].checkpoints.count - 1 {
            loadCheckpoint(at: checkpointIndex+1)
        }
    }
    
    func showPrevCheckpoint() {
        if checkpointIndex > 0 {
			loadCheckpoint(at: checkpointIndex-1)
        }
    }
    
    
    // Handles the saving of user input to UserDefaults
    @IBAction func handleSubmit(_ sender: UIButton) {
		
		let defaults = UserDefaults.standard
		
		let cp = checkpoints[checkpointIndex]
        switch cp.type {
        case .fieldEntry:
			if (cp.instances.count > 0) {
				defaults.set(inputField1.text, forKey: keyForInstanceIndex(1))
			}
			if (cp.instances.count > 1) {
				defaults.set(inputField2.text, forKey: keyForInstanceIndex(2))
			}
			if (cp.instances.count > 2) {
				defaults.set(inputField3.text, forKey: keyForInstanceIndex(3))
			}
			
        case .checkboxEntry:
            for (index, checkbox) in checkboxesButtons.enumerated() {
				if (index < cp.instances.count) {
					defaults.set(checkbox.isSelected, forKey: keyForInstanceIndex(index+1))
				}
            }
			
        case .radioEntry:
            for (index, radio) in radioButtons.enumerated() {
				if (index < cp.instances.count) {
					defaults.set(radio.isSelected, forKey: keyForInstanceIndex(index+1))
					print("\(keyForInstanceIndex(index+1)): \(radio.isSelected)")
				}
            }
			
        case .dateAndTextEntry:
			if (cp.instances.count > 0) {
				let key1 = keyForInstanceIndex(1)
				defaults.set(inputFieldDate1.text, forKey: "\(key1)_field")
				defaults.set(inputDate1.title(for: .normal), forKey: "\(key1)_date")
			}
			if (cp.instances.count > 1) {
				let key2 = keyForInstanceIndex(2)
				defaults.set(inputFieldDate2.text, forKey: "\(key2)_field")
				defaults.set(inputDate2.title(for: .normal), forKey: "\(key2)_date")
			}
			if (cp.instances.count > 2) {
				let key3 = keyForInstanceIndex(3)
				defaults.set(inputFieldDate3.text, forKey: "\(key3)_field")
				defaults.set(inputDate3.title(for: .normal), forKey: "\(key3)_date")
			}
		
		case .infoEntry:
			// nothing to persist here
			break
        }
		
		defaults.synchronize()
    }
	
	
	// MARK: Keyboard Handling
	
    private dynamic func keyboardDidShow(notification: NSNotification) {
		
		dismissDatePicker()
		
		guard let userInfo = notification.userInfo,
			  let r = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue
		else {
			return
		}
		
		// get the height of the keyboard
		keyboardHeight = r.cgRectValue.height
		
		// get the active text field
		guard let textField = self.activeTextField() else {
			return
		}
		
		// convert the text field bounds to the coordinates of the top level view (so they can be compared to the keyboard position)
		let textFieldBounds = textField.convert(textField.bounds, to: self.view)
		let textFieldBottom = textFieldBounds.maxY
		
		// get the top of the keyboard
		let keyboardTop = self.view.frame.maxY - keyboardHeight
		
		// calculate the offset required to move the view to avoid the top of the keyboard
		var offset = keyboardTop - textFieldBottom - (unadjustedOffset - outerTopConstraint.constant)
		if (offset > unadjustedOffset) {
			offset = unadjustedOffset
		}
		
		// animate the moving of the text field by adjusting the top constraint of the outer stack view
		self.view.layoutIfNeeded()
		UIView.animate(withDuration: 0.3, animations: {
			self.outerTopConstraint.constant = offset
			self.view.layoutIfNeeded()
		})
    }
    
    private dynamic func keyboardWillHide(notification: NSNotification) {
        
        // animate the moving back of the contents by resetting the top constraint of the outer stack view
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
            self.outerTopConstraint.constant = self.unadjustedOffset
            self.view.layoutIfNeeded()
        })
    }
    
    private dynamic func doneWithKeyboard(btn: UIButton) {
        self.view.endEditing(true)
    }
	
	private dynamic func nextField(btn: UIButton) {
		
		let activeStack: UIStackView = (!fieldStackview.isHidden ? fieldStackview : fieldDateStackview)
		
		var foundCurrent = false
		for subview in activeStack.arrangedSubviews {
			
			if let textField = subview as? UITextField {
				
				if !foundCurrent && textField.isFirstResponder {
					foundCurrent = true
					continue
				}
				
				if foundCurrent {
					textField.becomeFirstResponder()
					return
				}
			}
		}
	}
	
	private dynamic func previousField(btn: UIButton) {

		let activeStack: UIStackView = (!fieldStackview.isHidden ? fieldStackview : fieldDateStackview)
		
		var foundCurrent = false
		for subview in activeStack.arrangedSubviews.reversed() {
			
			if let textField = subview as? UITextField {
				
				if !foundCurrent && textField.isFirstResponder {
					foundCurrent = true
					continue
				}
				
				if foundCurrent {
					textField.becomeFirstResponder()
					return
				}
			}
		}
	}
	
    private dynamic func doneWithDatePicker(btn: UIButton){
        self.view.endEditing(true)
    }
    
    private func activeTextField() -> UITextField? {
		
        // ask each of the subviews of the text field stack view if it is the first responder
        for view in self.fieldStackview.arrangedSubviews {
            if view.isFirstResponder {
                return view as? UITextField
            }
        }
		
		// ask each of the subviews of the text field date stack view if it is the first responder
		for view in self.fieldDateStackview.arrangedSubviews {
			if view.isFirstResponder {
				return view as? UITextField
			}
		}
		
        // did not find any active text fields
        return nil
    }
    
    
    // Makes sure that Radio buttons are mutually exclusive
    @IBAction func handleRadio(_ sender: UIButton) {
        
        for radio in radioButtons {
            radio.isSelected = false
        }
        
        sender.isSelected = true
    }
    
    // Since checkboxes are not native to iOS development, this keeps track if the button representing them is selected
    @IBAction func handleCheckbox(_ sender: UIButton) {
		
		sender.isSelected = !sender.isSelected
    }
    
    // Handles the Field Date checkpoint date input, needs to be updated such that it handles all date inputs
    @IBAction func fieldDatePressed(_ button: UIButton) {
		
		// dismiss the keyboard
		self.view.endEditing(true)
		
		// toggle date picker visible/hidden
		pickerPaletteView.isHidden = false
		UIView.animate(withDuration: 0.3) {
            let top = (self.datePaletteVisible ? self.view.bounds.size.height : self.view.bounds.size.height - self.pickerPaletteView.frame.size.height);
            self.pickerPaletteView.frame = CGRect(x: 0, y: top, width: self.view.bounds.size.width, height: self.pickerPaletteView.frame.size.height)
            self.datePaletteVisible = !self.datePaletteVisible
        }
		
		// keep track of which button triggered the date picker
		currentInputDate = (datePaletteVisible ? button : nil)
    }
	
	func fieldDatePickerHandler(_ datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
		dateFormatter.timeStyle = .none
        let strDate = dateFormatter.string(from: datePicker.date)
        currentInputDate?.setTitle(strDate, for: .normal)
    }
	
    func dismissDatePicker() {
        
        UIView.animate(withDuration: 0.3) {
            self.pickerPaletteView.frame = CGRect(x: 0, y: self.view.bounds.size.height, width: self.view.bounds.size.width, height: self.pickerPaletteView.frame.size.height)
        }
        datePaletteVisible = false
    }
	
    
    func showMoreInfo() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "webview") as! WebViewController
        vc.url = CheckpointManager.shared.checkpoints[checkpointIndex].moreInfoURL!
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


