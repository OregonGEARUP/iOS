//
//  ViewController.swift
//  OR GEAR UP iOS JSON Parsing
//
//  Created by Max MacEachern on 9/26/16.
//  Copyright © 2016 Max MacEachern. All rights reserved.
//

import UIKit



class WebViewController: UIViewController {
    var url: String!
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = URLRequest(url: URL(string:self.url)!)
        self.webView.loadRequest(request)
    }
}


class ViewController: UIViewController {
    
<<<<<<< HEAD
    // Outlets for the UI Elements shared by all checkpoint types
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var moreInfoButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var PrevButton: UIButton!
    @IBOutlet weak var NextButton: UIButton!
    
    // Field checkpoint UI Elements
=======
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var moreInfoButton: UIButton!
    @IBOutlet weak var PrevButton: UIButton!
    @IBOutlet weak var NextButton: UIButton!
>>>>>>> origin/master
    @IBOutlet weak var fieldLabel1: UILabel!
    @IBOutlet weak var inputField1: UITextField!
    @IBOutlet weak var fieldLabel2: UILabel!
    @IBOutlet weak var inputField2: UITextField!
    @IBOutlet weak var fieldLabel3: UILabel!
    @IBOutlet weak var inputField3: UITextField!
<<<<<<< HEAD
    
    // Radiobutton collection
    @IBOutlet var radioButtons: [UIButton]!
    
    // Stackview UI Elements
    @IBOutlet weak var fieldStackview: UIStackView!
    @IBOutlet weak var checkboxStackview: UIStackView!
    @IBOutlet weak var radioStackview: UIStackView!
    @IBOutlet weak var fieldDateStackview: UIStackView!
    
    // Field Date checkpoint UI elements
    @IBOutlet weak var fieldDateLabel1: UILabel!
    @IBOutlet weak var inputDate1: UITextField!
    @IBOutlet weak var inputFieldDate1: UITextField!
    @IBOutlet weak var fieldDateLabel2: UILabel!
    @IBOutlet weak var inputFieldDate2: UITextField!
    @IBOutlet weak var inputDate2: UITextField!
    @IBOutlet weak var fieldDateLabel3: UILabel!
    @IBOutlet weak var inputFieldDate3: UITextField!
    @IBOutlet weak var inputDate3: UITextField!
    @IBOutlet weak var fieldDatePicker: UIDatePicker!
    
    @IBOutlet weak var pickerPaletteView: UIView!
    
    // Checkbox UI Elements
    @IBOutlet var checkboxesButtons: [UIButton]!
    
    
    @IBOutlet weak var outerTopConstraint: NSLayoutConstraint!
    
    // View used for keyboard avoidance
    private var keyboardAccessoryView: UIView? = nil

    var cpIndex: Int = 0
    var paletteVisible = false
    
    
    func loadCP(index: Int){
        
        // Access CheckpointManager (singleton)
        let cp = CheckpointManager.sharedManager.checkpoints[index]
        
        // Set Title, Description, & More Info
        self.titleLabel.text = cp.title
        
        self.descriptionLabel.text = cp.description
        
        if let moreInfo = cp.moreInfo {
         
            self.moreInfoButton.setTitle(moreInfo, for: .normal)
            
            
=======
    @IBOutlet var radioButtons: [UIButton]!
    @IBOutlet weak var groupStackview: UIStackView!
    @IBOutlet weak var fieldStackview: UIStackView!
    @IBOutlet weak var checkboxStackview: UIStackView!
    @IBOutlet weak var radioStackview: UIStackView!
    @IBOutlet var checkboxesButtons: [UIButton]!

    var cpIndex: Int = 0
    
    func loadCP(index: Int){
        let cp = CheckpointManager.sharedManager.checkpoints[index]
        
        self.titleLabel.text = cp.title
        self.descriptionLabel.text = cp.description
        
        if let moreInfo = cp.moreInfo {
            self.moreInfoButton.setTitle(moreInfo, for: .normal)
>>>>>>> origin/master
            self.moreInfoButton.isHidden = false
        } else {
            self.moreInfoButton.isHidden = true
        }
        
<<<<<<< HEAD
        // Set type
        let type = cp.entry.type
        
        
        // Display checkpoint, loads existing input from UserDefaults
        // TODO: Convert storyboard field and fieldDate checkpoints to collections so they can be dynamically iterated over. Could probably make a generalized show/hide stackview function.
=======
        let type = cp.entry.type
>>>>>>> origin/master
        switch type {
        case .FieldEntry:
            showStack(stack: fieldStackview)
            hideStack(stack: checkboxStackview)
            hideStack(stack: radioStackview)
<<<<<<< HEAD
            hideStack(stack: fieldDateStackview)
            
            self.fieldLabel1.text = cp.entry.instances[0].prompt
            self.fieldLabel2.text = cp.entry.instances[1].prompt
            self.fieldLabel3.text = cp.entry.instances[2].prompt
            
            // Set up UserDefaults to store user data
            let defaults = UserDefaults.standard
            
            if let inputFieldContent1 = defaults.string(forKey: "fkey1") {
                inputField1.text = inputFieldContent1
            } else {
                inputField1.becomeFirstResponder()
            }
            
            if let inputFieldContent2 = defaults.string(forKey: "fkey2") {
                inputField2.text = inputFieldContent2
            } else {
               
                inputField2.becomeFirstResponder()
            }
            if let inputFieldContent3 = defaults.string(forKey: "fkey3") {
                inputField3.text = inputFieldContent3
            } else {
                inputField3.becomeFirstResponder()
            }
=======
            self.fieldLabel1.text = cp.entry.instances[0].prompt
            self.fieldLabel2.text = cp.entry.instances[1].prompt
            self.fieldLabel3.text = cp.entry.instances[2].prompt
>>>>>>> origin/master
        
        case .CheckboxEntry:
            showStack(stack: checkboxStackview)
            hideStack(stack: fieldStackview)
            hideStack(stack: radioStackview)
<<<<<<< HEAD
            hideStack(stack: fieldDateStackview)
            
            
            let defaults = UserDefaults.standard
            var checkboxIndex: Int = 0
            
            for checkbox in checkboxesButtons {
                checkbox.setTitle(cp.entry.instances[checkboxIndex].prompt, for: .normal)
                checkbox.setTitle(cp.entry.instances[checkboxIndex].prompt, for: .selected)
                let cbKey = (titleLabel.text! + (checkbox.titleLabel?.text!)!)
                if defaults.bool(forKey: cbKey) == true {
                    checkbox.isSelected = true
                } else {
                    checkbox.isSelected = false
                }
                
=======
            var checkboxIndex: Int = 0
            for checkbox in checkboxesButtons {
                checkbox.setTitle(cp.entry.instances[checkboxIndex].prompt, for: .normal)
                checkbox.setTitle(cp.entry.instances[checkboxIndex].prompt, for: .selected)
>>>>>>> origin/master
                checkboxIndex += 1
            }
            
        case .RadioEntry:
            showStack(stack: radioStackview)
            hideStack(stack: fieldStackview)
            hideStack(stack: checkboxStackview)
<<<<<<< HEAD
            hideStack(stack: fieldDateStackview)
            var radiobuttonIndex: Int = 0
            let defaults = UserDefaults.standard
            for radio in radioButtons {
                //Used for testing
                //print("The current Radio Button Index is", radiobuttonIndex)
                //print(cp.entry.instances[radiobuttonIndex].prompt)
                radio.setTitle(cp.entry.instances[radiobuttonIndex].prompt, for: .normal)
                radio.setTitle(cp.entry.instances[radiobuttonIndex].prompt, for: .selected)
                let radioKey = (titleLabel.text! + (radio.titleLabel?.text!)!)
                if defaults.bool(forKey: radioKey) == true {
                    radio.isSelected = true
                } else {
                    radio.isSelected = false
                }
                //print(radio.titleLabel)
                radiobuttonIndex += 1
            }
            
        // Add UserDefaults loading once FieldDate collection has been implemented
=======
            var radiobuttonIndex: Int = 0
            for radio in radioButtons {
                radio.setTitle(cp.entry.instances[radiobuttonIndex].prompt, for: .normal)
                radio.setTitle(cp.entry.instances[radiobuttonIndex].prompt, for: .selected)
                radiobuttonIndex += 1
            }
        
>>>>>>> origin/master
        case .FieldDateEntry:
            hideStack(stack: fieldStackview)
            hideStack(stack: checkboxStackview)
            hideStack(stack: radioStackview)
<<<<<<< HEAD
            showStack(stack: fieldDateStackview)
            self.fieldDateLabel1.text = cp.entry.instances[0].prompt
            self.fieldDateLabel2.text = cp.entry.instances[1].prompt
            self.fieldDateLabel3.text = cp.entry.instances[2].prompt

=======
>>>>>>> origin/master
        }
        
        
    }
<<<<<<< HEAD
    
    // Next and Previous CP function to navigate between checkpoints
=======
>>>>>>> origin/master
    func nextCP(){
        let maxCP = CheckpointManager.sharedManager.checkpoints.count
        if cpIndex < maxCP-1 {
            cpIndex = cpIndex + 1
            loadCP(index: cpIndex)
        }
    }
    
    func prevCP(){
        if cpIndex > 0 {
            cpIndex = cpIndex - 1
            loadCP(index: cpIndex)
        }
    }
    
<<<<<<< HEAD
    
    // Handles the saving of user input to UserDefaults
    @IBAction func handleSubmit(_ sender: UIButton) {
        
        let cp = CheckpointManager.sharedManager.checkpoints[cpIndex]

        let type = cp.entry.type
        
        switch type {
        case .FieldEntry:
            let defaults = UserDefaults.standard
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
            
        case.CheckboxEntry:
            let defaults = UserDefaults.standard
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
            for key in keyHolder {
                print(defaults.object(forKey: key))
            }
        
        case.RadioEntry:
            let defaults = UserDefaults.standard
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
            for key in radioKeyHolder {
                print(defaults.object(forKey: key))
            }
        
        case .FieldDateEntry:
            
            let defaults = UserDefaults.standard
            defaults.set(inputFieldDate1.text, forKey: "fdfield1")
            defaults.set(inputDate1.text, forKey: "fddate1")
            defaults.set(inputFieldDate2.text, forKey: "fdfield2")
            defaults.set(inputDate2.text, forKey: "fddate2")
            defaults.set(inputFieldDate3.text, forKey: "fdfield3")
            defaults.set(inputDate3.text, forKey: "fddate3")
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
    
    
=======
>>>>>>> origin/master
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Checkpoint"
        
<<<<<<< HEAD
        //Adds hanlders for moreInfo, Next and Prev buttons
=======
>>>>>>> origin/master
        self.moreInfoButton.addTarget(self, action: #selector(showMoreInfo), for: .touchUpInside)
        
        self.NextButton.addTarget(self, action: #selector(nextCP), for: .touchUpInside)
        
        self.PrevButton.addTarget(self, action: #selector(prevCP), for: .touchUpInside)
        
<<<<<<< HEAD
        // Asynchronous call for JSON information
=======
        
>>>>>>> origin/master
        CheckpointManager.sharedManager.fetchJSON() { (success) in
            
            print("fetchJSON was successful: \(success)")
            
            
            self.loadCP(index: self.cpIndex)
            
       }
        
<<<<<<< HEAD
        // The following code implements a done button for the keyboard
        self.keyboardAccessoryView = UIView(frame: CGRect(x:0.0, y:0.0, width:0.0, height:40.0))
        self.keyboardAccessoryView?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.95)
        
        let doneBtn = UIButton(type: .system)
        doneBtn.translatesAutoresizingMaskIntoConstraints = false
        doneBtn.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
        doneBtn.addTarget(self, action: #selector(doneWithKeyboard(btn:)), for: .touchUpInside)
        self.keyboardAccessoryView?.addSubview(doneBtn)
        
        let views = ["doneBtn": doneBtn]
        var allConstraints = [NSLayoutConstraint]()
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[doneBtn]|", options: [], metrics: nil, views: views)
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[doneBtn]-20-|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(allConstraints)
        
        for subview in self.fieldStackview.arrangedSubviews {
            if let textField = subview as? UITextField {
                textField.inputAccessoryView = keyboardAccessoryView
            }
        }
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // hookup the keyboard show/hide notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: Notification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        
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
        self.pickerPaletteView.frame = CGRect(x: 0, y: self.view.bounds.size.height, width: self.view.bounds.size.width, height: pickerPaletteView.frame.size.height)
    }
    
    private dynamic func keyboardDidShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo, let r = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue
            else { return }
        
        // get the active text field
        guard let textField = self.activeTextField() else {
            return
        }
        
        // get the height of the keyboard
        let kbHeight = r.cgRectValue.height
        
        // convert the text field bounds to the coordinates of the top level view (so they can be compared to the keyboard position)
        let textFieldBounds = textField.convert(textField.bounds, to: self.view)
        let textFieldBottom = textFieldBounds.maxY
        
        // get the top of the keyboard
        let kbTop = self.view.frame.maxY - kbHeight
        
        // see if we need to move the text field to avoid the keyboard
        if (textFieldBottom < kbTop)
        {
            return
        }
        
        // animate the moving of the text field by adjusting the top constraint of the outer stack view
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
            let offset = textFieldBottom - kbTop
            self.outerTopConstraint.constant = -offset
            self.view.layoutIfNeeded()
        })
    }
    
    private dynamic func keyboardDidHide(notification: NSNotification) {
        
        // animate the moving back of the contents by resetting the top constraint of the outer stack view
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
            self.outerTopConstraint.constant = 8
            self.view.layoutIfNeeded()
        })
    }
    
    private dynamic func doneWithKeyboard(btn: UIButton) {
        self.view.endEditing(true)
    }
    
    private dynamic func doneWithDatePicker(btn: UIButton){
        self.view.endEditing(true)
    }
    
    private func activeTextField() -> UITextField? {
        
        // if the text field stack is hidden then no active text field
        guard !self.fieldStackview.isHidden else {
            return nil
        }
        
        // ask each of the subviews of the text field stack view if it is the first responder
        for view in self.fieldStackview.arrangedSubviews {
            if view.isFirstResponder {
                return view as? UITextField
            }
        }
        
        // did not find any active text fields
        return nil
    }
    
    
    // Makes sure that Radio buttons are mutually exclusive
=======
        
    }
>>>>>>> origin/master
    @IBAction func handleRadio(_ sender: UIButton) {
        
        for radio in radioButtons {
            radio.isSelected = false
        }
        
        sender.isSelected = true
<<<<<<< HEAD
        

    }
    
    // Since checkboxes are not native to iOS development, this keeps track if the button representing them is selected
=======

    }
>>>>>>> origin/master
    @IBAction func handleCheckbox(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected

    }
    
<<<<<<< HEAD
    // Handles the Field Date checkpoint date input, needs to be updated such that it handles all date inputs
    @IBAction func fieldDatePressed(_ sender: AnyObject) {

        UIView.animate(withDuration: 0.3) {
            let top = (self.paletteVisible ? self.view.bounds.size.height : self.view.bounds.size.height - self.pickerPaletteView.frame.size.height);
            self.pickerPaletteView.frame = CGRect(x: 0, y: top, width: self.view.bounds.size.width, height: self.pickerPaletteView.frame.size.height)
            self.paletteVisible = !self.paletteVisible
        }
        let doneBtn = UIButton(type: .system)
        doneBtn.translatesAutoresizingMaskIntoConstraints = false
        doneBtn.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
        doneBtn.addTarget(self, action: #selector(DPdoneButton), for: .touchUpInside)
        self.pickerPaletteView?.addSubview(doneBtn)
        
        let views = ["doneBtn": doneBtn]
        var allConstraints = [NSLayoutConstraint]()
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[doneBtn]|", options: [], metrics: nil, views: views)
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[doneBtn]-20-|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(allConstraints)
        

        fieldDatePicker.addTarget(self, action: #selector(fieldDateHandler), for: UIControlEvents.valueChanged)
        
    }
    
    func fieldDateHandler(sender: UIDatePicker, currentfield: UITextField){
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var strDate = dateFormatter.string(from: fieldDatePicker.date)
        self.inputDate1.text = strDate
    }
    
    func DPdoneButton(sender:UIButton){
        
        UIView.animate(withDuration: 0.3) {
            self.pickerPaletteView.frame = CGRect(x: 0, y: self.view.bounds.size.height, width: self.view.bounds.size.width, height: self.pickerPaletteView.frame.size.height)
            //self.paletteVisible = !self.paletteVisible
        }
        inputDate1.resignFirstResponder()
    }

=======
>>>>>>> origin/master
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideStack(stack: UIStackView){
        stack.isHidden = true
    }
    
    func showStack(stack: UIStackView){
        stack.isHidden = false
    }
    
<<<<<<< HEAD
    
=======
    // TODO: Make a generalized Stackview show/hide function
    /*func stackviewLoop(stack: UIStackView, groupStack: UIStackView){
        for stackview in groupStack {
            if stackview == stack {
                showStack(stackview)
            }
            else {
                hideStack(stack: stackview)
            }
        }
    }*/
>>>>>>> origin/master
    func showMoreInfo() {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "webview") as! WebViewController
        vc.url = CheckpointManager.sharedManager.checkpoints[cpIndex].moreInfo!
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
