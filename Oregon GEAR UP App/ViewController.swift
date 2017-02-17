//
//  ViewController.swift
//  Oregon GEAR UP App
//
//  Created by Max MacEachern on 11/28/16.
//  Copyright © 2016 Oregon GEAR UP. All rights reserved.
//

import UIKit


class WebViewController: UIViewController {
    var urlStr: String?
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if let urlStr = urlStr, let ulr = URL(string:urlStr) {
			let request = URLRequest(url: ulr)
			self.webView.loadRequest(request)
		}
    }
}


class ViewController: UIViewController {
    
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
    
    var checkpointIndex: Int = 0
    var datePaletteVisible = false
	
	
	// MARK: - View Controller Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = NSLocalizedString("Checkpoint", comment: "checking screen title")
		
		// add hanlders for moreInfo, Next and Prev buttons
		moreInfoButton.addTarget(self, action: #selector(showMoreInfo), for: .touchUpInside)
		nextButton.addTarget(self, action: #selector(showNextCheckPoint), for: .touchUpInside)
		prevButton.addTarget(self, action: #selector(showPrevCheckPoint), for: .touchUpInside)
		
		// empty the UI until we have data to drive it
		titleLabel.text = nil
		descriptionLabel.text = nil
		moreInfoButton.setTitle(nil, for: .normal)
		fieldStackview.isHidden = true
		checkboxStackview.isHidden = true
		radioStackview.isHidden = true
		fieldDateStackview.isHidden = true
		
		// load the JSON checkpoint information
		CheckpointManager.sharedManager.fetchJSON() { (success) in
			
			if success {
				self.loadCheckpoint(at: self.checkpointIndex)
			} else {
				// TODO: show error here?
			}
		}
		
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
	
	func loadCheckpoint(at index: Int){
		
        // Access CheckpointManager (singleton)
        let cp = CheckpointManager.sharedManager.checkpoints[index]
		
        // Set Title, Description, & More Info
        titleLabel.text = cp.title
		
        descriptionLabel.text = cp.description
		
        if let moreInfo = cp.moreInfo {
            moreInfoButton.setTitle(moreInfo, for: .normal)
			moreInfoButton.setTitle("https://oregongoestocollege.org", for: .normal)
            moreInfoButton.isHidden = false
        } else {
            moreInfoButton.isHidden = true
        }
		
        
        // Display checkpoint and load existing input from UserDefaults
		setupStackViews(forEntryType:cp.entry.type)
		
		let defaults = UserDefaults.standard
		
		switch cp.entry.type {
        case .fieldEntry:
			
            fieldLabel1.text = cp.entry.instances[0].prompt
            fieldLabel2.text = cp.entry.instances[1].prompt
            fieldLabel3.text = cp.entry.instances[2].prompt
			
            // Restore user data
            if let inputFieldContent1 = defaults.string(forKey: "fkey1") {
                inputField1.text = inputFieldContent1
            }
            if let inputFieldContent2 = defaults.string(forKey: "fkey2") {
                inputField2.text = inputFieldContent2
            }
            if let inputFieldContent3 = defaults.string(forKey: "fkey3") {
                inputField3.text = inputFieldContent3
            }
		
        case .checkboxEntry:
            for (index, checkbox) in checkboxesButtons.enumerated() {
                checkbox.setTitle(cp.entry.instances[index].prompt, for: .normal)
				
                let cbKey = (titleLabel.text! + (checkbox.titleLabel?.text!)!)		// TODO: need a unique key here
                checkbox.isSelected = defaults.bool(forKey: cbKey)
            }
		
        case .radioEntry:
            for (index, radio) in radioButtons.enumerated() {
                radio.setTitle(cp.entry.instances[index].prompt, for: .normal)
				
				let radioKey = (titleLabel.text! + (radio.titleLabel?.text!)!)		// TODO: need a unique key here
                radio.isSelected = defaults.bool(forKey: radioKey)
            }
		
        // Add UserDefaults loading once FieldDate collection has been implemented
        case .fieldDateEntry:
			
            fieldDateLabel1.text = cp.entry.instances[0].prompt
            fieldDateLabel2.text = cp.entry.instances[1].prompt
            fieldDateLabel3.text = cp.entry.instances[2].prompt
			
			// Restore user data
            if let inputFieldDateContent1 = defaults.string(forKey: "fdfield1") {
                inputFieldDate1.text = inputFieldDateContent1
            }
            if let inputDateContent1 = defaults.string(forKey: "fddate1"){
                inputDate1.setTitle(inputDateContent1, for: .normal)
            }
            if let inputFieldDateContent2 = defaults.string(forKey: "fdfield2") {
                inputFieldDate2.text = inputFieldDateContent2
            }
            if let inputDateContent2 = defaults.string(forKey: "fddate2"){
                inputDate2.setTitle(inputDateContent2, for: .normal)
            }
            if let inputFieldDateContent3 = defaults.string(forKey: "fdfield3") {
                inputFieldDate3.text = inputFieldDateContent3
            }
            if let inputDateContent3 = defaults.string(forKey: "fddate3"){
                inputDate3.setTitle(inputDateContent3, for: .normal)
            }
        }
    }
	
	func setupStackViews(forEntryType type: EntryType) {
		fieldStackview.isHidden = (type != .fieldEntry)
		checkboxStackview.isHidden = (type != .checkboxEntry)
		radioStackview.isHidden = (type != .radioEntry)
		fieldDateStackview.isHidden = (type != .fieldDateEntry)
	}
	
    // next and previous checkpoint functions to navigate between checkpoints
    func showNextCheckPoint() {
        let maxCP = CheckpointManager.sharedManager.checkpoints.count - 1
        if checkpointIndex < maxCP {
            checkpointIndex += 1
            loadCheckpoint(at: checkpointIndex)
        }
    }
    
    func showPrevCheckPoint() {
        if checkpointIndex > 0 {
            checkpointIndex -= 1
			loadCheckpoint(at: checkpointIndex)
        }
    }
    
    
    // Handles the saving of user input to UserDefaults
    @IBAction func handleSubmit(_ sender: UIButton) {
        
        let cp = CheckpointManager.sharedManager.checkpoints[checkpointIndex]
        
        let type = cp.entry.type
		let defaults = UserDefaults.standard
		
        switch type {
        case .fieldEntry:
            defaults.set(inputField1.text, forKey: "fkey1")
            defaults.set(inputField2.text, forKey: "fkey2")
            defaults.set(inputField3.text, forKey: "fkey3")
            // synchronize() updates UserDefaults to make sure you are working with current data
            defaults.synchronize()
            
            // Used for testing
            // let testField1 = defaults.object(forKey: "fkey1")
            // let testField2 = defaults.object(forKey: "fkey2")
            // let testField3 = defaults.object(forKey: "fkey3")
            // print(testField1, testField2, testField3)
            
        case .checkboxEntry:
            var keyHolder: [String] = []
            for checkbox in checkboxesButtons{
                if checkbox.isSelected {
                    defaults.set(true, forKey: titleLabel.text! + (checkbox.titleLabel?.text!)!)
                    keyHolder.append(titleLabel.text! + (checkbox.titleLabel?.text!)!)
                    //print(titleLabel.text! + (checkbox.titleLabel?.text!)!)
                }
                else {
                    defaults.set(false, forKey: titleLabel.text! + (checkbox.titleLabel?.text!)!)
                    keyHolder.append(titleLabel.text! + (checkbox.titleLabel?.text!)!)
                }
            }
            defaults.synchronize()
//            for key in keyHolder {
//                print(defaults.object(forKey: key))
//            }
			
        case .radioEntry:
            var radioKeyHolder: [String] = []
            for radiobtn in radioButtons {
                if radiobtn.isSelected {
                    defaults.set(true, forKey: titleLabel.text! + (radiobtn.titleLabel?.text!)!)
                    radioKeyHolder.append(titleLabel.text! + (radiobtn.titleLabel?.text!)!)
                }
                else {
                    defaults.set(false, forKey: "radiobtnKey")
                    radioKeyHolder.append(titleLabel.text! + (radiobtn.titleLabel?.text!)!)
                }
            }
            defaults.synchronize()
//            for key in radioKeyHolder {
//                print(defaults.object(forKey: key))
//            }
            
        case .fieldDateEntry:
            defaults.set(inputFieldDate1.text, forKey: "fdfield1")
            defaults.set(inputDate1.title(for: .normal), forKey: "fddate1")
            defaults.set(inputFieldDate2.text, forKey: "fdfield2")
            defaults.set(inputDate2.title(for: .normal), forKey: "fddate2")
            defaults.set(inputFieldDate3.text, forKey: "fdfield3")
            defaults.set(inputDate3.title(for: .normal), forKey: "fddate3")
            defaults.synchronize()
            //            Used for testing
            //            let testFDfield1 = defaults.object(forKey: "fdfield1")
            //            let testFDDate1 = defaults.object(forKey: "fddate1")
            //            let testFDfield2 = defaults.object(forKey: "fdfield2")
            //            let testFDDate2 = defaults.object(forKey: "fddate2")
            //            let testFDfield3 = defaults.object(forKey: "fdfield3")
            //            let testFDDate3 = defaults.object(forKey: "fddate3")
            //
            //            print(testFDfield1, testFDDate1, testFDfield2, testFDDate2, testFDfield3, testFDDate3)
        }
    }
    
	
	// MARK: Keyboard Handling
	
    private dynamic func keyboardDidShow(notification: NSNotification) {
		
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
		
		// toggle date picker visible/hidden
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
	
    func dismissDatePicker(sender:UIButton){
        
        UIView.animate(withDuration: 0.3) {
            self.pickerPaletteView.frame = CGRect(x: 0, y: self.view.bounds.size.height, width: self.view.bounds.size.width, height: self.pickerPaletteView.frame.size.height)
        }
        datePaletteVisible = false
    }
	
    
    func showMoreInfo() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "webview") as! WebViewController
        vc.urlStr = CheckpointManager.sharedManager.checkpoints[checkpointIndex].moreInfo!
		vc.urlStr = "https://oregongoestocollege.org"
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


