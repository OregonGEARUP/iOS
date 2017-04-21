//
//  StageViewController.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 3/12/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import UIKit


class CheckpointView: UIView {
	public let maxInstances = 3
	
	public let titleLabel = UILabel()
	public let descriptionLabel = UILabel()
	public let moreInfoButton = UIButton(type: .system)
	
	public let stackView = UIStackView()
	
	public let incompeteLabel = UILabel()
}

class InfoCheckpointView: CheckpointView {
}

class FieldsCheckpointView: CheckpointView {
	public let fieldLabels = [UILabel(), UILabel(), UILabel()]
	public let textFields = [UITextField(), UITextField(), UITextField()]
}

class DatesCheckpointView: CheckpointView {
	public let fieldLabels = [UILabel(), UILabel(), UILabel()]
	public let textFields = [UITextField(), UITextField(), UITextField()]
	public let dateButtons = [UIButton(), UIButton(), UIButton()]
	public let dateTextPlaceholder = NSLocalizedString("tap here to select date", comment: "date text placeholder")
}

class CheckboxesCheckpointView: CheckpointView {
	public let checkboxes = [UIButton(), UIButton(), UIButton()]
}

class RadiosCheckpointView: CheckpointView {
	public let radios = [UIButton(), UIButton(), UIButton()]
}

class RouteCheckpointView: CheckpointView {
}


class StageViewController: UIViewController {
	
	enum CheckpointAnimation {
		case none
		case fromLeft
		case fromRight
	}

	var blockIndex = 0
	var stageIndex = 0
	var checkpointIndex = 0
	
	var routeFilename: String?
	
	private var keyboardAccessoryView: UIView!
	
	private let datePickerPaletteHeight: CGFloat = 170.0
	private var datePickerPaletteView: UIView!
	private var datePickerTopConstraint: NSLayoutConstraint!
	private var currentInputDate: UIButton?
	
	var checkpointView: CheckpointView!
	var checkpointCenterXConstraint: NSLayoutConstraint!
	
	private var checkpoints: [Checkpoint] {
		return CheckpointManager.shared.blocks[blockIndex].stages[stageIndex].checkpoints
	}
	
	private func keyForInstanceIndex(_ instanceIndex: Int) -> String {
		return CheckpointManager.shared.keyForBlockIndex(blockIndex, stageIndex: stageIndex, checkpointIndex: checkpointIndex, instanceIndex: instanceIndex)
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = CheckpointManager.shared.blocks[blockIndex].stages[stageIndex].title
		
		createKeyboardAccessoryView()
		createDatePickerPaletteView()
		
		loadCheckpointAtIndex(checkpointIndex);
		
		let lpg = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
		view.addGestureRecognizer(lpg)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		saveCheckpointEntries()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	private func createCheckpointView(forType type: EntryType) -> CheckpointView {
		
		let cpView: CheckpointView!
		switch type {
		case .infoEntry:
			cpView = InfoCheckpointView()
		case .fieldEntry:
			cpView = FieldsCheckpointView()
		case .dateAndTextEntry,
		     .dateOnlyEntry:
			cpView = DatesCheckpointView()
		case .checkboxEntry:
			cpView = CheckboxesCheckpointView()
		case .radioEntry:
			cpView = RadiosCheckpointView()
		case .routeEntry:
			cpView = RouteCheckpointView()
		}
		
		cpView.layer.backgroundColor = UIColor(white: 1.0, alpha: 1.0).cgColor
		cpView.layer.borderColor = UIColor.lightGray.cgColor
		cpView.layer.borderWidth = 0.5
		cpView.layer.cornerRadius = 5.0
		
		cpView.translatesAutoresizingMaskIntoConstraints = false
		
		cpView.titleLabel.translatesAutoresizingMaskIntoConstraints = false
		cpView.titleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
		cpView.titleLabel.textAlignment = .center
		cpView.titleLabel.numberOfLines = 1
		cpView.addSubview(cpView.titleLabel)
		NSLayoutConstraint.activate([
			cpView.titleLabel.topAnchor.constraint(equalTo: cpView.topAnchor, constant: 20.0),
			cpView.titleLabel.leadingAnchor.constraint(equalTo: cpView.leadingAnchor, constant: 8.0),
			cpView.titleLabel.trailingAnchor.constraint(equalTo: cpView.trailingAnchor, constant: -8.0)
		])
		
		cpView.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		cpView.descriptionLabel.font = UIFont.systemFont(ofSize: 18.0)
		cpView.descriptionLabel.textAlignment = .left
		cpView.descriptionLabel.numberOfLines = 0
		cpView.addSubview(cpView.descriptionLabel)
		NSLayoutConstraint.activate([
			cpView.descriptionLabel.topAnchor.constraint(equalTo: cpView.titleLabel.bottomAnchor, constant: 8.0),
			cpView.descriptionLabel.leadingAnchor.constraint(equalTo: cpView.leadingAnchor, constant: 8.0),
			cpView.descriptionLabel.trailingAnchor.constraint(equalTo: cpView.trailingAnchor, constant: -8.0)
		])
		
		cpView.stackView.translatesAutoresizingMaskIntoConstraints = false
		cpView.stackView.axis = .vertical
		cpView.stackView.alignment = .fill
		cpView.stackView.distribution = .fill
		cpView.stackView.spacing = 8.0
		cpView.addSubview(cpView.stackView)
		NSLayoutConstraint.activate([
			cpView.stackView.topAnchor.constraint(equalTo: cpView.descriptionLabel.bottomAnchor, constant: 20.0),
			cpView.stackView.leadingAnchor.constraint(equalTo: cpView.leadingAnchor, constant: 8.0),
			cpView.stackView.trailingAnchor.constraint(equalTo: cpView.trailingAnchor, constant: -8.0)
		])
		
		switch type {
		case .infoEntry, .routeEntry:
			break
			
		case .fieldEntry:
			let fieldsCPView = cpView as! FieldsCheckpointView
			for i in 0..<cpView.maxInstances {
				fieldsCPView.fieldLabels[i].translatesAutoresizingMaskIntoConstraints = false
				fieldsCPView.fieldLabels[i].font = UIFont.systemFont(ofSize: 18.0)
				fieldsCPView.fieldLabels[i].textAlignment = .left
				fieldsCPView.fieldLabels[i].numberOfLines = 1
				cpView.stackView.addArrangedSubview(fieldsCPView.fieldLabels[i])
				
				fieldsCPView.textFields[i].translatesAutoresizingMaskIntoConstraints = false
				fieldsCPView.textFields[i].borderStyle = .roundedRect
				fieldsCPView.textFields[i].inputAccessoryView = keyboardAccessoryView
				cpView.stackView.addArrangedSubview(fieldsCPView.textFields[i])
				
				let spacer = UIView()
				cpView.stackView.addArrangedSubview(spacer)
				let hc2 = spacer.heightAnchor.constraint(equalToConstant: 8.0)
				hc2.priority = UILayoutPriorityRequired - 1
				hc2.isActive = true
			}
			
		case .dateAndTextEntry,
		     .dateOnlyEntry:
			let datesCPView = cpView as! DatesCheckpointView
			for i in 0..<cpView.maxInstances {
				datesCPView.fieldLabels[i].translatesAutoresizingMaskIntoConstraints = false
				datesCPView.fieldLabels[i].font = UIFont.systemFont(ofSize: 18.0)
				datesCPView.fieldLabels[i].textAlignment = .left
				datesCPView.fieldLabels[i].numberOfLines = 1
				cpView.stackView.addArrangedSubview(datesCPView.fieldLabels[i])
				
				datesCPView.textFields[i].translatesAutoresizingMaskIntoConstraints = false
				datesCPView.textFields[i].borderStyle = .roundedRect
				datesCPView.textFields[i].inputAccessoryView = keyboardAccessoryView
				cpView.stackView.addArrangedSubview(datesCPView.textFields[i])
				
				datesCPView.dateButtons[i].translatesAutoresizingMaskIntoConstraints = false
				datesCPView.dateButtons[i].contentHorizontalAlignment = .left
				datesCPView.dateButtons[i].contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
				datesCPView.dateButtons[i].layer.backgroundColor = UIColor.white.cgColor
				datesCPView.dateButtons[i].layer.borderColor = UIColor(white: 0.8, alpha: 1.0).cgColor
				datesCPView.dateButtons[i].layer.borderWidth = 0.5
				datesCPView.dateButtons[i].layer.cornerRadius = 5.0
				datesCPView.dateButtons[i].setTitleColor(.darkText, for: .normal)
				datesCPView.dateButtons[i].addTarget(self, action: #selector(toggleDatePicker(_:)), for: .touchUpInside)
				cpView.stackView.addArrangedSubview(datesCPView.dateButtons[i])
				let hc1 = datesCPView.dateButtons[i].heightAnchor.constraint(equalToConstant: 30.0)
				hc1.priority = UILayoutPriorityRequired - 1
				hc1.isActive = true
				
				let spacer = UIView()
				cpView.stackView.addArrangedSubview(spacer)
				let hc2 = spacer.heightAnchor.constraint(equalToConstant: 8.0)
				hc2.priority = UILayoutPriorityRequired - 1
				hc2.isActive = true
			}
			
		case .checkboxEntry:
			cpView.stackView.alignment = .leading
			let checkboxesCPView = cpView as! CheckboxesCheckpointView
			for i in 0..<cpView.maxInstances {
				checkboxesCPView.checkboxes[i].setImage(UIImage(named: "Checkbox"), for: .normal)
				checkboxesCPView.checkboxes[i].setImage(UIImage(named: "Checkbox_Checked"), for: .selected)
				checkboxesCPView.checkboxes[i].setTitleColor(.darkText, for: .normal)
				checkboxesCPView.checkboxes[i].contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
				checkboxesCPView.checkboxes[i].imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 0)
				checkboxesCPView.checkboxes[i].titleLabel?.adjustsFontSizeToFitWidth = true
				checkboxesCPView.checkboxes[i].titleLabel?.minimumScaleFactor = 0.7
				checkboxesCPView.checkboxes[i].addTarget(self, action: #selector(handleCheckbox(_:)), for: .touchUpInside)
				cpView.stackView.addArrangedSubview(checkboxesCPView.checkboxes[i])
			}
			
		case .radioEntry:
			cpView.stackView.alignment = .leading
			let radiosCPView = cpView as! RadiosCheckpointView
			for i in 0..<cpView.maxInstances {
				radiosCPView.radios[i].setImage(UIImage(named: "Radio"), for: .normal)
				radiosCPView.radios[i].setImage(UIImage(named: "Radio_On"), for: .selected)
				radiosCPView.radios[i].setTitleColor(.darkText, for: .normal)
				radiosCPView.radios[i].contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
				radiosCPView.radios[i].imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 0)
				radiosCPView.radios[i].titleLabel?.adjustsFontSizeToFitWidth = true
				radiosCPView.radios[i].titleLabel?.minimumScaleFactor = 0.7
				radiosCPView.radios[i].addTarget(self, action: #selector(handleRadio(_:)), for: .touchUpInside)
				cpView.stackView.addArrangedSubview(radiosCPView.radios[i])
			}
		}
		
		cpView.moreInfoButton.translatesAutoresizingMaskIntoConstraints = false
		cpView.moreInfoButton.addTarget(self, action: #selector(showMoreInfo), for: .touchUpInside)
		cpView.addSubview(cpView.moreInfoButton)
		NSLayoutConstraint.activate([
			cpView.moreInfoButton.bottomAnchor.constraint(equalTo: cpView.bottomAnchor, constant: -18.0),
			cpView.moreInfoButton.centerXAnchor.constraint(equalTo: cpView.centerXAnchor),
		])
		
		cpView.incompeteLabel.translatesAutoresizingMaskIntoConstraints = false
		cpView.incompeteLabel.text = NSLocalizedString("You must complete this before proceeding.", comment:"incomplete checkpoint message")
		cpView.incompeteLabel.font = UIFont.systemFont(ofSize: 18.0)
		cpView.incompeteLabel.textColor = .red
		cpView.incompeteLabel.textAlignment = .center
		cpView.incompeteLabel.numberOfLines = 0
		cpView.incompeteLabel.alpha = 0.0
		cpView.addSubview(cpView.incompeteLabel)
		NSLayoutConstraint.activate([
			cpView.incompeteLabel.bottomAnchor.constraint(equalTo: cpView.moreInfoButton.topAnchor, constant: -20.0),
			cpView.incompeteLabel.leadingAnchor.constraint(equalTo: cpView.leadingAnchor, constant: 8.0),
			cpView.incompeteLabel.trailingAnchor.constraint(equalTo: cpView.trailingAnchor, constant: -8.0)
		])

		return cpView
	}
	
	private func populateCheckpointView(_ cpView: CheckpointView, with checkPoint: Checkpoint) {
		
		cpView.titleLabel.text = checkPoint.titleSubstituted
		cpView.descriptionLabel.text = checkPoint.descriptionSubstituted
		
		if let url = checkPoint.moreInfoURL {
			if let linkText = checkPoint.moreInfoSubstituted {
				cpView.moreInfoButton.setTitle(linkText, for: .normal)
			} else {
				cpView.moreInfoButton.setTitle(url.absoluteString, for: .normal)
			}
			cpView.moreInfoButton.isHidden = false
		} else {
			cpView.moreInfoButton.isHidden = true
		}
		
		let defaults = UserDefaults.standard
		
		switch checkPoint.type {
		case .infoEntry, .routeEntry:
			break
			
		case .fieldEntry:
			let fieldsCPView = cpView as! FieldsCheckpointView
			for i in 0..<cpView.maxInstances {
				if (i < checkPoint.instances.count) {
					fieldsCPView.fieldLabels[i].isHidden = false
					fieldsCPView.textFields[i].isHidden = false
					fieldsCPView.fieldLabels[i].text = checkPoint.instances[i].promptSubstituted
					fieldsCPView.textFields[i].placeholder = checkPoint.instances[i].placeholderSubstituted
					fieldsCPView.textFields[i].text = defaults.string(forKey: keyForInstanceIndex(i))
				} else {
					fieldsCPView.fieldLabels[i].isHidden = true
					fieldsCPView.textFields[i].isHidden = true
				}
			}
		
		case .dateAndTextEntry,
		     .dateOnlyEntry:
			let datesCPView = cpView as! DatesCheckpointView
			for i in 0..<cpView.maxInstances {
				if (i < checkPoint.instances.count) {
					datesCPView.fieldLabels[i].isHidden = false
					datesCPView.textFields[i].isHidden = (checkPoint.type == .dateOnlyEntry)
					datesCPView.dateButtons[i].isHidden = false
					datesCPView.fieldLabels[i].text = checkPoint.instances[i].promptSubstituted
					datesCPView.textFields[i].placeholder = checkPoint.instances[i].placeholderSubstituted
					
					let key = keyForInstanceIndex(i)
					datesCPView.textFields[i].text = defaults.string(forKey: "\(key)_text")
					if let dateStr = defaults.string(forKey: "\(key)_date") {
						datesCPView.dateButtons[i].setTitle(dateStr, for: .normal)
						datesCPView.dateButtons[i].setTitleColor(.darkText, for: .normal)
					} else {
						datesCPView.dateButtons[i].setTitle(datesCPView.dateTextPlaceholder, for: .normal)
						datesCPView.dateButtons[i].setTitleColor(.lightGray, for: .normal)
					}
				} else {
					datesCPView.fieldLabels[i].isHidden = true
					datesCPView.textFields[i].isHidden = true
					datesCPView.dateButtons[i].isHidden = true
				}
			}
			
		case .checkboxEntry:
			let checkboxesCPView = cpView as! CheckboxesCheckpointView
			for i in 0..<cpView.maxInstances {
				if (i < checkPoint.instances.count) {
					checkboxesCPView.checkboxes[i].isHidden = false
					checkboxesCPView.checkboxes[i].setTitle(checkPoint.instances[i].promptSubstituted, for: .normal)
					checkboxesCPView.checkboxes[i].isSelected = defaults.bool(forKey: keyForInstanceIndex(i))
				} else {
					checkboxesCPView.checkboxes[i].isHidden = true
				}
			}
		
		case .radioEntry:
			let radiosCPView = cpView as! RadiosCheckpointView
			for i in 0..<cpView.maxInstances {
				if (i < checkPoint.instances.count) {
					radiosCPView.radios[i].isHidden = false
					radiosCPView.radios[i].setTitle(checkPoint.instances[i].promptSubstituted, for: .normal)
					radiosCPView.radios[i].isSelected = defaults.bool(forKey: keyForInstanceIndex(i))
				} else {
					radiosCPView.radios[i].isHidden = true
				}
			}
		}
	}
	
	private func isCurrentCheckpointCompleted() -> Bool {
		
		let checkPoint = checkpoints[checkpointIndex]
		switch checkPoint.type {
		case .infoEntry, .routeEntry:
			return true
			
		case .fieldEntry:
			let fieldsCPView = checkpointView as! FieldsCheckpointView
			for i in 0..<checkPoint.instances.count {
				if let text = fieldsCPView.textFields[i].text {
					if text.isEmpty {
						return false
					}
				} else {
					return false
				}
			}
			return true
			
		case .dateAndTextEntry,
		     .dateOnlyEntry:
			let datesCPView = checkpointView as! DatesCheckpointView
			for i in 0..<checkPoint.instances.count {
				if checkPoint.type == .dateAndTextEntry {
					if let text = datesCPView.textFields[i].text {
						if text.isEmpty {
							return false
						}
					} else {
						return false
					}
				}
				
				if let text = datesCPView.dateButtons[i].title(for: .normal) {
					if text.isEmpty {
						return false
					}
				} else {
					return false
				}
			}
			return true
			
		case .checkboxEntry:
//			let checkboxesCPView = checkpointView as! CheckboxesCheckpointView
//			for i in 0..<checkPoint.instances.count {
//				if checkboxesCPView.checkboxes[i].isSelected {
//					return true
//				}
//			}
//			return false
			return true
			
		case .radioEntry:
			let radiosCPView = checkpointView as! RadiosCheckpointView
			for i in 0..<checkPoint.instances.count {
				if radiosCPView.radios[i].isSelected {
					return true
				}
			}
			return false
		}
	}
	
	private func saveCheckpointEntries() {
		
		let defaults = UserDefaults.standard
		
		let checkPoint = checkpoints[checkpointIndex]
		switch checkPoint.type {
		case .infoEntry, .routeEntry:
			break
			
		case .fieldEntry:
			let fieldsCPView = checkpointView as! FieldsCheckpointView
			for i in 0..<checkPoint.instances.count {
				defaults.set(fieldsCPView.textFields[i].text, forKey: keyForInstanceIndex(i))
			}
			
		case .dateAndTextEntry,
		     .dateOnlyEntry:
			let datesCPView = checkpointView as! DatesCheckpointView
			for i in 0..<checkPoint.instances.count {
				let key = keyForInstanceIndex(i)
				if checkPoint.type == .dateAndTextEntry {
					defaults.set(datesCPView.textFields[i].text, forKey: "\(key)_text")
				}
				
				if let text = datesCPView.dateButtons[i].title(for: .normal), text != datesCPView.dateTextPlaceholder {
					defaults.set(text, forKey: "\(key)_date")
				} else {
					defaults.removeObject(forKey: "\(key)_date")
				}
			}
			
		case .checkboxEntry:
			let checkboxesCPView = checkpointView as! CheckboxesCheckpointView
			for i in 0..<checkPoint.instances.count {
				defaults.set(checkboxesCPView.checkboxes[i].isSelected, forKey: keyForInstanceIndex(i))
			}
			
		case .radioEntry:
			let radiosCPView = checkpointView as! RadiosCheckpointView
			for i in 0..<checkPoint.instances.count {
				defaults.set(radiosCPView.radios[i].isSelected, forKey: keyForInstanceIndex(i))
			}
		}
	}
	
	private func createKeyboardAccessoryView() {
		
		// add a done button for the keyboard
		keyboardAccessoryView = UIView(frame: CGRect(x:0.0, y:0.0, width:0.0, height:40.0))
		keyboardAccessoryView.backgroundColor = UIColor(red: 0.7790, green: 0.7963, blue: 0.8216, alpha: 0.9)
		
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
	}
	
	private func createDatePickerPaletteView() {
		
		datePickerPaletteView = UIView()
		datePickerPaletteView.translatesAutoresizingMaskIntoConstraints = false
		datePickerPaletteView.backgroundColor = UIColor(white: 0.9, alpha: 0.9)
		view.addSubview(datePickerPaletteView)
		datePickerTopConstraint = datePickerPaletteView.topAnchor.constraint(equalTo: self.view.bottomAnchor)
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
		
		let datePicker = UIDatePicker()
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
	
	func showMoreInfo() {
		let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "webview") as! WebViewController
		vc.url = checkpoints[checkpointIndex].moreInfoURL!
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
	@IBAction func handleCheckbox(_ sender: UIButton) {
		
		sender.isSelected = !sender.isSelected
	}

	@IBAction func handleRadio(_ sender: UIButton) {
		
		let radiosCPView = checkpointView as! RadiosCheckpointView
		for radio in radiosCPView.radios {
			radio.isSelected = false
		}
		
		sender.isSelected = true
	}

	private dynamic func doneWithKeyboard(btn: UIButton) {
		
		self.view.endEditing(true)
	}
	
	private dynamic func nextField(btn: UIButton) {
		
		var foundCurrent = false
		for subview in checkpointView.stackView.arrangedSubviews {
			
			if let textField = subview as? UITextField, !textField.isHidden {
				
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
		
		var foundCurrent = false
		for subview in checkpointView.stackView.arrangedSubviews.reversed() {
			
			if let textField = subview as? UITextField, !textField.isHidden {
				
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
	
	private dynamic func toggleDatePicker(_ button: UIButton) {
		
		// hide keyboard first
		self.view.endEditing(true)
		
		// track whether picker will become visible
		let datePickerVisible = (datePickerTopConstraint.constant == 0)
		
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
		
		currentInputDate?.setTitle(strDate, for: .normal)
		currentInputDate?.setTitleColor(.darkText, for: .normal)
	}
	
	@IBAction func nextCheckpoint(_ button: UIButton) {
		
		// check to see if required entry checkpoint is completed
		if checkpoints[checkpointIndex].required && !isCurrentCheckpointCompleted() {
			
			UIView.animate(withDuration: 0.3, animations: { 
				self.checkpointView.incompeteLabel.alpha = 1.0
			})
			return
		}
		
		saveCheckpointEntries()
		
		// if current checkpoint is a route entry, then do the navigation
		if checkpoints[checkpointIndex].type == .routeEntry {
			
			routeFilename = checkpoints[checkpointIndex].routeFileName
			performSegue(withIdentifier: "unwindToNewBlock", sender: self)
			return
		}
		
		
		var nextIndex = checkpointIndex + 1
		while nextIndex < checkpoints.count {
			
			if checkpoints[nextIndex].type == .routeEntry {
				
				let meetsCriteria = checkpoints[nextIndex].meetsCriteria
				print("meetsCriteria: \(meetsCriteria)")
				
				if (!meetsCriteria) {
					
					// skip this checkpoint
					if nextIndex + 1 < checkpoints.count {
						nextIndex += 1
						continue
					} else {
						
						// ran out of checkpoints, nothing more to do
						return
					}
				}
			}
			
			loadCheckpointAtIndex(nextIndex, withAnimation: .fromRight)
			return
		}
		
		// if we get to here, then we have run out of checkpoints
		
		// first check to see if there are more stages
		let nextStageIndex = stageIndex + 1
		if nextStageIndex < CheckpointManager.shared.blocks[blockIndex].stages.count {
			
			let message = NSLocalizedString("You have reached the end of this section.", comment: "end of section message")
			let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: NSLocalizedString("Keep Going!", comment: "Keep Going! button title"), style: .default, handler: { (action) in
				self.stageIndex = nextStageIndex
				self.title = CheckpointManager.shared.blocks[self.blockIndex].stages[self.stageIndex].title
				self.loadCheckpointAtIndex(0, withAnimation: .fromRight)
			}))
			alertController.addAction(UIAlertAction(title: NSLocalizedString("Home", comment: "Home button title"), style: .cancel, handler: { (action) in
				self.navigationController?.popViewController(animated: true)
			}))
			self.present(alertController, animated: true, completion: nil)
			
			return
		}
		
		// getting here is an error
		//fatalError("ran out of checkpoints in block: \(blockIndex)  stage: \(stageIndex)")
	}
	
	@IBAction func previousCheckpoint(_ button: UIButton) {
		
		saveCheckpointEntries()
		
		if checkpointIndex > 0 {
			loadCheckpointAtIndex(checkpointIndex - 1, withAnimation: .fromLeft)
		}
	}
	
	private func loadCheckpointAtIndex(_ index: Int, withAnimation animation: CheckpointAnimation = .none) {
		
		checkpointIndex = index
		CheckpointManager.shared.persistState(forBlock: blockIndex, stage: stageIndex, checkpoint: checkpointIndex)
		
		switch animation {
		case .none:
			checkpointView = createCheckpointView(forType: checkpoints[checkpointIndex].type)
			populateCheckpointView(checkpointView, with: checkpoints[checkpointIndex])
			view.insertSubview(checkpointView, at: 0)
			
			checkpointCenterXConstraint = checkpointView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
			NSLayoutConstraint.activate([
				checkpointView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.80),
				checkpointCenterXConstraint,
//				checkpointView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.70),
//				checkpointView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0.0),
				checkpointView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 16.0),
				checkpointView.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor, constant: -48.0)
			])
			
		case .fromLeft, .fromRight:
			let newCheckpointView = createCheckpointView(forType: checkpoints[checkpointIndex].type)
			populateCheckpointView(newCheckpointView, with: checkpoints[checkpointIndex])
			view.insertSubview(newCheckpointView, at: 0)
			
			// offset new checkpoint view horizontally and then animate it into center postion
			let offset: CGFloat = (animation == .fromRight ? 400.0 : -400.0)
			let newCheckpointCenterXConstraint = newCheckpointView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: offset)
			NSLayoutConstraint.activate([
				newCheckpointView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.80),
				newCheckpointCenterXConstraint,
//				newCheckpointView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.70),
//				newCheckpointView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0.0),
				newCheckpointView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 16.0),
				newCheckpointView.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor, constant: -48.0)
			])
			
			//newCheckpointView.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
			
			view.layoutIfNeeded()
			UIView.animate(withDuration: 0.3, animations: {
				self.checkpointCenterXConstraint.constant = -offset
				newCheckpointCenterXConstraint.constant = 0.0
				newCheckpointView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
				self.view.layoutIfNeeded()
			}, completion: { (complete) in
				self.checkpointCenterXConstraint = newCheckpointCenterXConstraint
				self.checkpointView.removeFromSuperview()
				self.checkpointView = newCheckpointView
			})
		}
	}
	
	private dynamic func handleLongPress(_ gr: UILongPressGestureRecognizer) {
		
		if gr.state != .began {
			return
		}
		
		if let hitView = view.hitTest(gr.location(ofTouch: 0, in: view), with: nil) {
			
			var hitKey: String? = nil
			switch checkpoints[checkpointIndex].type {
			case .infoEntry, .routeEntry:
				break
			
			case .fieldEntry:
				let fieldsCPView = checkpointView as! FieldsCheckpointView
				for (index, field) in fieldsCPView.textFields.enumerated() {
					if field == hitView {
						hitKey = keyForInstanceIndex(index)
					}
				}
			
			case .dateAndTextEntry,
			     .dateOnlyEntry:
				let datesCPView = checkpointView as! DatesCheckpointView
				for (index, field) in datesCPView.textFields.enumerated() {
					if field == hitView {
						hitKey = keyForInstanceIndex(index) + "_text"
					}
				}
				for (index, button) in datesCPView.dateButtons.enumerated() {
					if button == hitView {
						hitKey = keyForInstanceIndex(index) + "_date"
					}
				}
			
			case .checkboxEntry:
				let checkboxesCPView = checkpointView as! CheckboxesCheckpointView
				for (index, checkbox) in checkboxesCPView.checkboxes.enumerated() {
					if checkbox == hitView {
						hitKey = keyForInstanceIndex(index)
					}
				}
				
			case .radioEntry:
				let radiosCPView = checkpointView as! RadiosCheckpointView
				for (index, radio) in radiosCPView.radios.enumerated() {
					if radio == hitView {
						hitKey = keyForInstanceIndex(index)
					}
				}
			}
			
			if let hitKey = hitKey {
				let alert = UIAlertController(title: "Instance Key", message: hitKey, preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
				present(alert, animated: true, completion: nil)
			}
		}
	}
}

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
