//
//  StageViewController.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 3/12/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import UIKit
import MessageUI


class CheckpointView: UIView {
	public let maxInstances = 6
	
	var blockIndex = -1
	var stageIndex = -1
	var checkpointIndex = -1
	
	public func keyForInstanceIndex(_ instanceIndex: Int) -> String {
		return CheckpointManager.shared.keyForBlockIndex(blockIndex, stageIndex: stageIndex, checkpointIndex: checkpointIndex, instanceIndex: instanceIndex)
	}
	
	public let titleLabel = UILabel()
	public let descriptionLabel = UILabel()
	public let moreInfoButton = UIButton(type: .system)
	public let moreInfoShareButton = UIButton(type: .custom)
	
	public let stackView = UIStackView()
	
	public let incompeteLabel = UILabel()
}

class InfoCheckpointView: CheckpointView {
}

class FieldsCheckpointView: CheckpointView {
	public let fieldLabels = [UILabel(), UILabel(), UILabel(), UILabel(), UILabel(), UILabel()]
	public let textFields = [UITextField(), UITextField(), UITextField(), UITextField(), UITextField(), UITextField()]
}

class DatesCheckpointView: CheckpointView {
	public let fieldLabels = [UILabel(), UILabel(), UILabel(), UILabel(), UILabel(), UILabel()]
	public let textFields = [UITextField(), UITextField(), UITextField(), UITextField(), UITextField(), UITextField()]
	public let dateButtons = [UIButton(), UIButton(), UIButton(), UIButton(), UIButton(), UIButton()]
	public let dateTextPlaceholder = NSLocalizedString("tap here to select date", comment: "date text placeholder")
}

class CheckboxesCheckpointView: CheckpointView {
	public let checkboxes = [UIButton(), UIButton(), UIButton(), UIButton(), UIButton(), UIButton()]
}

class RadiosCheckpointView: CheckpointView {
	public let radios = [UIButton(), UIButton(), UIButton(), UIButton(), UIButton(), UIButton()]
}

class RouteCheckpointView: CheckpointView {
	public let nextBlockButton = UIButton()
}


class StageViewController: UIViewController, MFMailComposeViewControllerDelegate {
	
	enum CheckpointAnimation {
		case none
		case fromLeft
		case fromRight
	}

	var blockIndex = 0
	var stageIndex = 0
	var checkpointIndex = 0
	
	var checkpointView: CheckpointView!
	var currentXConstraint: NSLayoutConstraint!
	
	var nextCheckpointIndex: Int?
	var nextCheckpointView: CheckpointView?
	var nextXConstraint: NSLayoutConstraint?
	var nextXConstant: CGFloat = 0.0
	
	var prevCheckpointIndex: Int?
	var prevCheckpointView: CheckpointView?
	var prevXConstraint: NSLayoutConstraint?
	var prevXConstant: CGFloat = 0.0
	
	
	var routeFilename: String?
	
	@IBOutlet var prevButton: UIButton!
	@IBOutlet var nextButton: UIButton!
	
	private var keyboardAccessoryView: UIView!
	
	private let datePickerPaletteHeight: CGFloat = 200.0
	private var datePickerPaletteView: UIView!
	private var datePicker: UIDatePicker!
	private var datePickerTopConstraint: NSLayoutConstraint!
	private var currentInputDate: UIButton?
	
	private var checkpoints: [Checkpoint] {
		return CheckpointManager.shared.block.stages[stageIndex].checkpoints
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = CheckpointManager.shared.block.stages[stageIndex].title
		
		nextButton.alpha = 0.0
		prevButton.alpha = 0.0
		
		createKeyboardAccessoryView()
		createDatePickerPaletteView()
		
		loadCheckpointAtIndex(checkpointIndex)
		
		let pgr = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
		view.addGestureRecognizer(pgr)
		
		NotificationCenter.default.addObserver(self, selector:#selector(keyboardDidShow(_:)), name:NSNotification.Name.UIKeyboardDidShow, object: nil)
		NotificationCenter.default.addObserver(self, selector:#selector(keyboardDidHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
		
		let lpg = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
		view.addGestureRecognizer(lpg)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		checkpointView?.alpha = 1.0
		nextCheckpointView?.alpha = 1.0
		prevCheckpointView?.alpha = 1.0
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		doneWithKeyboard(btn: nil)
		doneWithDatePicker()
		
		checkpointView?.alpha = 0.0
		nextCheckpointView?.alpha = 0.0
		prevCheckpointView?.alpha = 0.0
		
		saveCheckpointEntries()
		
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
		case .routeEntry, .nextStage:
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
		cpView.titleLabel.numberOfLines = 0
		cpView.titleLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
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
		cpView.descriptionLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
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
		case .infoEntry:
			break
		
		case .routeEntry, .nextStage:
			let routeCPView = cpView as! RouteCheckpointView
			let spacer = UIView()
			spacer.heightAnchor.constraint(equalToConstant: 90.0).isActive = true
			cpView.stackView.addArrangedSubview(spacer)
			routeCPView.nextBlockButton.setTitle(NSLocalizedString("Let's Keep Going!", comment: "button title for transition to next block"), for: .normal)
			routeCPView.nextBlockButton.setTitleColor(view.tintColor, for: .normal)		// button blue
			routeCPView.nextBlockButton.titleLabel?.font = UIFont.systemFont(ofSize: 22.0)
			if type == .routeEntry {
				routeCPView.nextBlockButton.addTarget(self, action: #selector(routeToNextBlock), for: .touchUpInside)
			} else {
				routeCPView.nextBlockButton.addTarget(self, action: #selector(loadNextStage), for: .touchUpInside)
			}
			cpView.stackView.addArrangedSubview(routeCPView.nextBlockButton)
			
		case .fieldEntry:
			let fieldsCPView = cpView as! FieldsCheckpointView
			for i in 0..<cpView.maxInstances {
				fieldsCPView.fieldLabels[i].translatesAutoresizingMaskIntoConstraints = false
				fieldsCPView.fieldLabels[i].font = UIFont.systemFont(ofSize: 18.0)
				fieldsCPView.fieldLabels[i].textAlignment = .left
				fieldsCPView.fieldLabels[i].numberOfLines = 0
				cpView.stackView.addArrangedSubview(fieldsCPView.fieldLabels[i])
				
				fieldsCPView.textFields[i].translatesAutoresizingMaskIntoConstraints = false
				fieldsCPView.textFields[i].borderStyle = .roundedRect
				fieldsCPView.textFields[i].inputAccessoryView = keyboardAccessoryView
				cpView.stackView.addArrangedSubview(fieldsCPView.textFields[i])
				
				let spacer = UIView()
				cpView.stackView.addArrangedSubview(spacer)
				let hc2 = spacer.heightAnchor.constraint(equalToConstant: 0.0)	// zero height spacer still incurs stack view spacing
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
				datesCPView.fieldLabels[i].numberOfLines = 0
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
				let hc2 = spacer.heightAnchor.constraint(equalToConstant: 0.0)	// zero height spacer still incurs stack view spacing
				hc2.priority = UILayoutPriorityRequired - 1
				hc2.isActive = true
			}
			
		case .checkboxEntry:
			cpView.stackView.alignment = .leading
			let checkboxesCPView = cpView as! CheckboxesCheckpointView
			for i in 0..<cpView.maxInstances {
				checkboxesCPView.checkboxes[i].translatesAutoresizingMaskIntoConstraints = false
				checkboxesCPView.checkboxes[i].addTarget(self, action: #selector(handleCheckbox(_:)), for: .touchUpInside)
				cpView.stackView.addArrangedSubview(checkboxesCPView.checkboxes[i])
				setupButton(checkboxesCPView.checkboxes[i], withText: "", image: #imageLiteral(resourceName: "Checkbox"))
			}
			
		case .radioEntry:
			cpView.stackView.alignment = .leading
			let radiosCPView = cpView as! RadiosCheckpointView
			for i in 0..<cpView.maxInstances {
				radiosCPView.radios[i].translatesAutoresizingMaskIntoConstraints = false
				radiosCPView.radios[i].addTarget(self, action: #selector(handleRadio(_:)), for: .touchUpInside)
				cpView.stackView.addArrangedSubview(radiosCPView.radios[i])
				setupButton(radiosCPView.radios[i], withText: "", image: #imageLiteral(resourceName: "Radio"))
			}
		}
		
		cpView.moreInfoButton.translatesAutoresizingMaskIntoConstraints = false
		cpView.moreInfoButton.titleLabel?.numberOfLines = 0
		cpView.moreInfoButton.addTarget(self, action: #selector(showMoreInfo), for: .touchUpInside)
		cpView.addSubview(cpView.moreInfoButton)
		NSLayoutConstraint.activate([
			cpView.moreInfoButton.bottomAnchor.constraint(equalTo: cpView.bottomAnchor, constant: -18.0),
			cpView.moreInfoButton.centerXAnchor.constraint(equalTo: cpView.centerXAnchor),
			cpView.moreInfoButton.widthAnchor.constraint(equalTo: cpView.widthAnchor, multiplier: 0.75),
		])
		
		cpView.moreInfoShareButton.translatesAutoresizingMaskIntoConstraints = false
		cpView.moreInfoShareButton.setImage(#imageLiteral(resourceName: "action").withRenderingMode(.alwaysTemplate), for: .normal)
		cpView.moreInfoShareButton.imageView?.tintColor = view.tintColor	// button blue
		cpView.moreInfoShareButton.adjustsImageWhenHighlighted = true
		cpView.moreInfoShareButton.addTarget(self, action: #selector(shareMoreInfo), for: .touchUpInside)
		cpView.addSubview(cpView.moreInfoShareButton)
		NSLayoutConstraint.activate([
			cpView.moreInfoShareButton.heightAnchor.constraint(equalToConstant: 40.0),
			cpView.moreInfoShareButton.widthAnchor.constraint(equalToConstant: 40.0),
			cpView.moreInfoShareButton.centerYAnchor.constraint(equalTo: cpView.moreInfoButton.centerYAnchor, constant: -3.0),
			cpView.moreInfoShareButton.rightAnchor.constraint(equalTo: cpView.rightAnchor, constant: -2.0)
		])
		
		cpView.incompeteLabel.translatesAutoresizingMaskIntoConstraints = false
		cpView.incompeteLabel.text = NSLocalizedString("You must complete this before proceeding.", comment:"incomplete checkpoint message")
		cpView.incompeteLabel.font = UIFont.systemFont(ofSize: 18.0)
		cpView.incompeteLabel.textColor = .red
		cpView.incompeteLabel.layer.cornerRadius = 3.0
		cpView.incompeteLabel.layer.backgroundColor = UIColor(colorLiteralRed: 1.0, green: 0.97, blue: 0.97, alpha: 1.0).cgColor
		cpView.incompeteLabel.textAlignment = .center
		cpView.incompeteLabel.numberOfLines = 0
		cpView.incompeteLabel.alpha = 0.0
		cpView.incompeteLabel.isUserInteractionEnabled = true
		cpView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissIncomplete)))
		cpView.addSubview(cpView.incompeteLabel)
		NSLayoutConstraint.activate([
			cpView.incompeteLabel.bottomAnchor.constraint(equalTo: cpView.bottomAnchor, constant: -12.0),
			cpView.incompeteLabel.leadingAnchor.constraint(equalTo: cpView.leadingAnchor, constant: 8.0),
			cpView.incompeteLabel.trailingAnchor.constraint(equalTo: cpView.trailingAnchor, constant: -8.0)
		])
		
		return cpView
	}
	
	private dynamic func dismissIncomplete() {
		UIView.animate(withDuration: 0.2) { 
			self.checkpointView.incompeteLabel.alpha = 0.0
		}
	}
	
	private func setupButton(_ button: UIButton, withText text: String, image: UIImage?) {
		
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.image = image
		imageView.tag = 100
		imageView.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
		button.addSubview(imageView)
		
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.textAlignment = .left
		label.textColor = .darkText
		label.font = UIFont.systemFont(ofSize: 18.0)
		label.text = text
		label.tag = 101
		button.addSubview(label)
		
		imageView.leftAnchor.constraint(equalTo: button.leftAnchor, constant: 0.0).isActive = true
		imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor, constant: 0.0).isActive = true
		
		label.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 7.0).isActive = true
		label.rightAnchor.constraint(equalTo: button.rightAnchor, constant: 0.0).isActive = true
		label.topAnchor.constraint(equalTo: button.topAnchor, constant: 0.0).isActive = true
		label.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: 0.0).isActive = true
		label.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
	}
	
	private func populateCheckpointView(_ cpView: CheckpointView, withCheckpointAtIndex cpIndex: Int) {
		
		cpView.blockIndex = blockIndex
		cpView.stageIndex = stageIndex
		cpView.checkpointIndex = cpIndex
		
		let checkPoint = checkpoints[cpIndex]
		
		cpView.titleLabel.text = checkPoint.titleSubstituted
		cpView.descriptionLabel.text = checkPoint.descriptionSubstituted
		
		if let url = checkPoint.moreInfoURL {
			if let linkText = checkPoint.moreInfoSubstituted {
				cpView.moreInfoButton.setTitle(linkText, for: .normal)
			} else {
				cpView.moreInfoButton.setTitle(url.absoluteString, for: .normal)
			}
			cpView.moreInfoButton.isHidden = false
			cpView.moreInfoShareButton.isHidden = url.absoluteString.hasPrefix("itsaplan:")
		} else {
			cpView.moreInfoButton.isHidden = true
			cpView.moreInfoShareButton.isHidden = true
		}
		
		let defaults = UserDefaults.standard
		
		switch checkPoint.type {
		case .infoEntry, .routeEntry:
			break
			
		case .nextStage:
			cpView.descriptionLabel.text = "You have reached the end of this section."
			
		case .fieldEntry:
			let fieldsCPView = cpView as! FieldsCheckpointView
			for i in 0..<cpView.maxInstances {
				if (i < checkPoint.instances.count) {
					fieldsCPView.fieldLabels[i].isHidden = false
					fieldsCPView.textFields[i].isHidden = false
					fieldsCPView.fieldLabels[i].text = checkPoint.instances[i].promptSubstituted
					fieldsCPView.textFields[i].placeholder = checkPoint.instances[i].placeholderSubstituted
					fieldsCPView.textFields[i].text = defaults.string(forKey: cpView.keyForInstanceIndex(i))
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
					
					let key = cpView.keyForInstanceIndex(i)
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
					if let label = checkboxesCPView.checkboxes[i].viewWithTag(101) as? UILabel {
						label.text = checkPoint.instances[i].promptSubstituted
					}
					checkboxesCPView.checkboxes[i].isSelected = defaults.bool(forKey: cpView.keyForInstanceIndex(i))
					if let imageView = checkboxesCPView.checkboxes[i].viewWithTag(100) as? UIImageView {
						imageView.image = checkboxesCPView.checkboxes[i].isSelected ? #imageLiteral(resourceName: "Checkbox_Checked") : #imageLiteral(resourceName: "Checkbox")
					}
				} else {
					checkboxesCPView.checkboxes[i].isHidden = true
				}
			}
		
		case .radioEntry:
			let radiosCPView = cpView as! RadiosCheckpointView
			for i in 0..<cpView.maxInstances {
				if (i < checkPoint.instances.count) {
					radiosCPView.radios[i].isHidden = false
					if let label = radiosCPView.radios[i].viewWithTag(101) as? UILabel {
						label.text = checkPoint.instances[i].promptSubstituted
					}
					radiosCPView.radios[i].isSelected = defaults.bool(forKey: cpView.keyForInstanceIndex(i))
					if let imageView = radiosCPView.radios[i].viewWithTag(100) as? UIImageView {
						imageView.image = radiosCPView.radios[i].isSelected ? #imageLiteral(resourceName: "Radio_On") : #imageLiteral(resourceName: "Radio")
					}
				} else {
					radiosCPView.radios[i].isHidden = true
				}
			}
		}
	}
	
	private func isCurrentCheckpointCompleted() -> Bool {
		
		let checkPoint = checkpoints[checkpointIndex]
		switch checkPoint.type {
		case .infoEntry, .routeEntry, .nextStage:
			return true
			
		case .fieldEntry:
			let fieldsCPView = checkpointView as! FieldsCheckpointView
			for i in 0..<min(checkpointView.maxInstances, checkPoint.instances.count) {
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
			for i in 0..<min(checkpointView.maxInstances, checkPoint.instances.count) {
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
			let checkboxesCPView = checkpointView as! CheckboxesCheckpointView
			for i in 0..<min(checkpointView.maxInstances, checkPoint.instances.count) {
				if checkboxesCPView.checkboxes[i].isSelected {
					return true
				}
			}
			return false
			
		case .radioEntry:
			let radiosCPView = checkpointView as! RadiosCheckpointView
			for i in 0..<min(checkpointView.maxInstances, checkPoint.instances.count) {
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
		case .infoEntry, .routeEntry, .nextStage:
			break
			
		case .fieldEntry:
			guard let fieldsCPView = checkpointView as? FieldsCheckpointView else {
				return
			}
			for i in 0..<min(checkpointView.maxInstances, checkPoint.instances.count) {
				let key = checkpointView.keyForInstanceIndex(i)
				defaults.set(fieldsCPView.textFields[i].text, forKey: key)
				let value = fieldsCPView.textFields[i].text ?? ""
				CheckpointManager.shared.addTrace("saved '\(value)' for '\(key)'")
			}
			
		case .dateAndTextEntry,
		     .dateOnlyEntry:
			guard let datesCPView = checkpointView as? DatesCheckpointView else {
				return
			}
			for i in 0..<min(checkpointView.maxInstances, checkPoint.instances.count) {
				let key = checkpointView.keyForInstanceIndex(i)
				if checkPoint.type == .dateAndTextEntry {
					defaults.set(datesCPView.textFields[i].text, forKey: "\(key)_text")
					let value = datesCPView.textFields[i].text ?? ""
					CheckpointManager.shared.addTrace("saved '\(value)' for '\(key)_text'")
				}
				
				if let text = datesCPView.dateButtons[i].title(for: .normal), text != datesCPView.dateTextPlaceholder {
					defaults.set(text, forKey: "\(key)_date")
					CheckpointManager.shared.addTrace("saved '\(text)' for '\(key)_date'")
				} else {
					defaults.removeObject(forKey: "\(key)_date")
				}
			}
			
		case .checkboxEntry:
			guard let checkboxesCPView = checkpointView as? CheckboxesCheckpointView else {
				return
			}
			for i in 0..<min(checkpointView.maxInstances, checkPoint.instances.count) {
				let key = checkpointView.keyForInstanceIndex(i)
				defaults.set(checkboxesCPView.checkboxes[i].isSelected, forKey: key)
				CheckpointManager.shared.addTrace("saved '\(checkboxesCPView.checkboxes[i].isSelected)' for '\(key)'")
			}
			
		case .radioEntry:
			guard let radiosCPView = checkpointView as? RadiosCheckpointView else {
				return
			}
			for i in 0..<min(checkpointView.maxInstances, checkPoint.instances.count) {
				let key = checkpointView.keyForInstanceIndex(i)
				defaults.set(radiosCPView.radios[i].isSelected, forKey: key)
				CheckpointManager.shared.addTrace("saved '\(radiosCPView.radios[i].isSelected)' for '\(key)'")
			}
		}
	}
	
	private func createKeyboardAccessoryView() {
		
		// add a done button for the keyboard
		keyboardAccessoryView = UIView(frame: CGRect(x:0.0, y:0.0, width:0.0, height:40.0))
		keyboardAccessoryView.backgroundColor = UIColor(red: 0.7790, green: 0.7963, blue: 0.8216, alpha: 0.9)
		
		
		let topLine = UIView()
		topLine.translatesAutoresizingMaskIntoConstraints = false
		topLine.backgroundColor = .gray
		keyboardAccessoryView.addSubview(topLine)
		
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
			topLine.topAnchor.constraint(equalTo: keyboardAccessoryView.topAnchor),
			topLine.widthAnchor.constraint(equalTo: keyboardAccessoryView.widthAnchor),
			topLine.heightAnchor.constraint(equalToConstant: 0.5),
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
		datePickerPaletteView.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 1.0, alpha: 1.0)
		view.addSubview(datePickerPaletteView)
		datePickerTopConstraint = datePickerPaletteView.topAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor)
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
	
	private dynamic func showMoreInfo() {
		
		// check for special app destination URLs first
		if let url = checkpoints[checkpointIndex].moreInfoURL {
			
			let urlstr = url.absoluteString
			if urlstr.hasPrefix("itsaplan://myplan/") {
				
				if let tbc = tabBarController, let vcs = tbc.viewControllers, let nc = vcs[1] as? UINavigationController {
					
					// pop back to root
					nc.popToRootViewController(animated: false)
					
					// then setup the section of My Plan to show
					if let myplanController = nc.visibleViewController as? MyPlanViewController {
						
						if urlstr.hasSuffix("colleges") {
							myplanController.planIndexToShow = 0
						} else if urlstr.hasSuffix("scholarships") {
							myplanController.planIndexToShow = 1
						} else if urlstr.hasSuffix("tests") {
							myplanController.planIndexToShow = 2
						} else if urlstr.hasSuffix("residency") {
							myplanController.planIndexToShow = 3
						} else {
							myplanController.planIndexToShow = -1
						}
					}
					
					// switch to My Plan tab
					tbc.selectedIndex = 1
				}
				
			} else if urlstr == "itsaplan://passwords" {
				
				// switch to Passwords tab
				tabBarController?.selectedIndex = 2
				
			} else if urlstr == "itsaplan://info" {
				
				// switch to Info tab
				tabBarController?.selectedIndex = 3
				
			} else {
				
				// open web page for URL
				let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "webview") as! WebViewController
				self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: "Back button"), style: .plain, target: nil, action: nil)
				vc.url = url
				self.navigationController?.pushViewController(vc, animated: true)
			}
		}
	}
	
	private dynamic func shareMoreInfo() {
		
		if let url = checkpoints[checkpointIndex].moreInfoURL {
			let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
			activityController.popoverPresentationController?.sourceView = checkpointView.moreInfoShareButton
			present(activityController, animated: true, completion: nil)
		}
	}
	
	@IBAction func handleCheckbox(_ sender: UIButton) {
		
		sender.isSelected = !sender.isSelected
		if let imageView = sender.viewWithTag(100) as? UIImageView {
			imageView.image = sender.isSelected ? #imageLiteral(resourceName: "Checkbox_Checked") : #imageLiteral(resourceName: "Checkbox")
		}
	}

	@IBAction func handleRadio(_ sender: UIButton) {
		
		let radiosCPView = checkpointView as! RadiosCheckpointView
		for radio in radiosCPView.radios {
			radio.isSelected = false
			if let imageView = radio.viewWithTag(100) as? UIImageView {
				imageView.image = #imageLiteral(resourceName: "Radio")
			}
		}
		
		sender.isSelected = true
		if let imageView = sender.viewWithTag(100) as? UIImageView {
			imageView.image = #imageLiteral(resourceName: "Radio_On")
		}
	}

	private dynamic func doneWithKeyboard(btn: UIButton?) {
		
		self.view.endEditing(true)
	}
	
	fileprivate dynamic func keyboardDidShow(_ notification: Notification) {
		
		doneWithDatePicker()
		
		guard let userInfo = notification.userInfo, let r = userInfo[UIKeyboardFrameEndUserInfoKey] else {
			return
		}
		
		var textField: UITextField?
		for subview in checkpointView.stackView.arrangedSubviews {
			if let tf = subview as? UITextField, !tf.isHidden, tf.isFirstResponder {
				textField = tf
				break
			}
		}
		
		guard textField != nil else {
			return
		}
		
		let kbHeigth = (r as AnyObject).cgRectValue.size.height
		let textFrame = textField!.convert(textField!.bounds, to: view)
		let textBottom = textFrame.maxY
		let kbTop = self.view.frame.maxY - kbHeigth
		
		if (textBottom < kbTop-16)
		{
			return
		}
		
		UIView.animate(withDuration: 0.3, animations: {
			let offset = textBottom - kbTop + 16
			self.view.frame = CGRect(x: 0.0, y: -offset, width: self.view.frame.width, height: self.view.frame.height)
		})
	}
	
	fileprivate dynamic func keyboardDidHide(_ notification: Notification) {
		UIView.animate(withDuration: 0.3, animations: {
			self.view.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height)
		})
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
		
		currentInputDate?.setTitle(strDate, for: .normal)
		currentInputDate?.setTitleColor(.darkText, for: .normal)
	}
	
	
	private dynamic func handleSwipe(_ gr: UIPanGestureRecognizer) {
		
		enum SwipeResult {
			case noChange
			case nextCheckpoint
			case prevCheckpoint
		}
		
		let translation = gr.translation(in: view).x
		
		if gr.state == .began || gr.state == .changed {
			
			currentXConstraint.constant = translation
			nextXConstraint?.constant = nextXConstant + translation
			prevXConstraint?.constant = prevXConstant + translation
			
			view.layoutIfNeeded()
			
		} else if gr.state == .ended || gr.state == .failed || gr.state == .cancelled {
			
			let highVelocity = fabs(gr.velocity(in: view).x) > 700
			let farEnough = fabs(translation) > nextXConstant * 0.6
			let completed = !checkpoints[checkpointIndex].required || isCurrentCheckpointCompleted()
			
			saveCheckpointEntries()
			
			var result = SwipeResult.noChange
			if gr.state == .ended && translation < 0.0 && completed && nextCheckpointView != nil && (highVelocity || farEnough) {
				result = .nextCheckpoint
			} else if gr.state == .ended && translation > 0.0 && prevCheckpointView != nil && prevCheckpointIndex != nil && (highVelocity || farEnough) {
				result = .prevCheckpoint
			}
			
			view.layoutIfNeeded()
			UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: {
				
				switch result {
				case .nextCheckpoint:
					self.currentXConstraint.constant = self.prevXConstant
					self.nextXConstraint?.constant = 0.0
					self.prevXConstraint?.constant = -10000.0
				
				case .prevCheckpoint:
					self.currentXConstraint.constant = self.nextXConstant
					self.nextXConstraint?.constant = 10000.0
					self.prevXConstraint?.constant = 0.0
					
				case .noChange:
					
					if !completed {
						self.checkpointView.incompeteLabel.alpha = 1.0
					}
					
					// put everyone back
					self.currentXConstraint.constant = 0.0
					self.nextXConstraint?.constant = self.nextXConstant
					self.prevXConstraint?.constant = self.prevXConstant
				}
				
				self.view.layoutIfNeeded()

			}, completion: { (finished) in
				
				switch result {
				case .nextCheckpoint:
					
					if self.nextCheckpointView != nil && self.nextCheckpointIndex != nil {
						
						self.prevCheckpointIndex = self.checkpointIndex
						self.prevCheckpointView = self.checkpointView
						self.prevXConstraint = self.currentXConstraint
						
						self.checkpointIndex = self.nextCheckpointIndex!
						self.checkpointView = self.nextCheckpointView
						self.currentXConstraint = self.nextXConstraint
						
						self.nextCheckpointView = nil
						self.nextXConstraint = nil
						
						self.loadNextCheckpointAfterIndex(self.checkpointIndex)
						
					}
					
				case .prevCheckpoint:
					
					self.nextCheckpointIndex = self.checkpointIndex
					self.nextCheckpointView = self.checkpointView
					self.nextXConstraint = self.currentXConstraint
					
					self.checkpointIndex = self.prevCheckpointIndex!
					self.checkpointView = self.prevCheckpointView
					self.currentXConstraint = self.prevXConstraint
					
					self.prevCheckpointView = nil
					self.prevXConstraint = nil
					
					self.loadPrevCheckpointBeforeIndex(self.checkpointIndex)
					
				case .noChange:
					break
				}
				
				CheckpointManager.shared.markVisited(forBlock: self.blockIndex, stage: self.stageIndex, checkpoint: self.checkpointIndex)
				CheckpointManager.shared.persistState(forBlock: self.blockIndex, stage: self.stageIndex, checkpoint: self.checkpointIndex)
			})
		}
	}
	
	private dynamic func loadNextStage() {
		
		guard self.stageIndex+1 < CheckpointManager.shared.block.stages.count else {
			return
		}
		
		self.nextCheckpointView?.removeFromSuperview()
		self.nextCheckpointView = nil
		self.prevCheckpointView?.removeFromSuperview()
		self.prevCheckpointView = nil
		self.checkpointView?.removeFromSuperview()
		self.checkpointView = nil
		
		self.stageIndex = self.stageIndex+1
		self.title = CheckpointManager.shared.block.stages[self.stageIndex].title
		self.loadCheckpointAtIndex(0)
	}
	
	private dynamic func routeToNextBlock() {
		guard checkpoints[checkpointIndex].type == .routeEntry, let blockFileName = checkpoints[checkpointIndex].routeFileName else {
			return
		}
		
		CheckpointManager.shared.addTrace("routeToNextBlock routing to: \(blockFileName)")
		
		self.routeFilename = blockFileName
		performSegue(withIdentifier: "unwindToNewBlock", sender: self)
	}
	
	@IBAction func nextCheckpoint(_ button: UIButton) {
		
		// check to see if required entry checkpoint is completed
		if checkpoints[checkpointIndex].required && !isCurrentCheckpointCompleted() {
			
			UIView.animate(withDuration: 0.3, animations: { 
				self.checkpointView.incompeteLabel.alpha = 1.0
			})
			
			CheckpointManager.shared.addTrace("nextCheckpoint incomplete")
			return
		}
		
		nextButton.isEnabled = false
		
		CheckpointManager.shared.addTrace("nextCheckpoint")
		
		saveCheckpointEntries()
		
		// if current checkpoint is a route entry, then do the navigation
		if checkpoints[checkpointIndex].type == .routeEntry {
			
			if let routeFilename = checkpoints[checkpointIndex].routeFileName {
				
				CheckpointManager.shared.addTrace("nextCheckpoint routing to: \(routeFilename)")
				
				self.routeFilename = routeFilename
				performSegue(withIdentifier: "unwindToNewBlock", sender: self)
				return
			}
		}
		
		
		var nextIndex = checkpointIndex + 1
		while nextIndex < checkpoints.count {
			
			if checkpoints[nextIndex].type == .routeEntry {
				
				var meetsCriteria = checkpoints[nextIndex].meetsCriteria
				
				print("meetsCriteria: \(meetsCriteria)")
				if meetsCriteria {
					if let filename = checkpoints[nextIndex].routeFileName {
						CheckpointManager.shared.addTrace("nextCheckpoint does meet criteria for \(CheckpointManager.shared.keyForBlockIndex(blockIndex, stageIndex: stageIndex, checkpointIndex: nextIndex)), will route to \(filename)")
					} else {
						CheckpointManager.shared.addTrace("nextCheckpoint does meet criteria for \(CheckpointManager.shared.keyForBlockIndex(blockIndex, stageIndex: stageIndex, checkpointIndex: nextIndex)), but is MISSING a routeFileName for route checkpoint")
						meetsCriteria = false
					}
				} else {
					CheckpointManager.shared.addTrace("nextCheckpoint does NOT meet criteria for \(CheckpointManager.shared.keyForBlockIndex(blockIndex, stageIndex: stageIndex, checkpointIndex: nextIndex))")
				}
				
				if !meetsCriteria {
					
					// unmet criteria == visited
					CheckpointManager.shared.markVisited(forBlock: blockIndex, stage: stageIndex, checkpoint: nextIndex)
					
					// skip this checkpoint
					if nextIndex + 1 < checkpoints.count {
						nextIndex += 1
						continue
					} else {
						
						// ran out of checkpoints, fall through to see if we have more stages
						break
					}
				}
			}
			
			loadCheckpointAtIndex(nextIndex, withAnimation: .fromRight)
			return
		}
		
		// if we get to here, then we have run out of checkpoints
		
		// first check to see if there are more stages
		let nextStageIndex = stageIndex + 1
		if nextStageIndex < CheckpointManager.shared.block.stages.count {
			
			CheckpointManager.shared.addTrace("nextCheckpoint proposing next stage \(CheckpointManager.shared.keyForBlockIndex(blockIndex, stageIndex: nextStageIndex, checkpointIndex: 0))")
			
			let message = NSLocalizedString("You have reached the end of this section.", comment: "end of section message")
			let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: NSLocalizedString("Keep Going!", comment: "Keep Going! button title"), style: .default, handler: { (action) in
				self.stageIndex = nextStageIndex
				self.title = CheckpointManager.shared.block.stages[self.stageIndex].title
				self.loadCheckpointAtIndex(0, withAnimation: .fromRight)
			}))
			alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button title"), style: .cancel, handler: nil))
			self.present(alertController, animated: true, completion: nil)
			
			nextButton.isEnabled = true
			return
		}
		
		// getting here is an error
		//fatalError("ran out of checkpoints in block: \(blockIndex)  stage: \(stageIndex)")
		CheckpointManager.shared.addTrace("nextCheckpoint ran out of checkpoints in block: \(blockIndex) stage: \(stageIndex)")
	}
	
	@IBAction func previousCheckpoint(_ button: UIButton) {
		
		prevButton.isEnabled = false
		
		CheckpointManager.shared.addTrace("previousCheckpoint")
		
		saveCheckpointEntries()
		
		if checkpointIndex > 0 {
			
			// skip over route cps when going back (we skipped them going forward)
			var prevIndex = checkpointIndex - 1
			while prevIndex >= 0 {
				if checkpoints[prevIndex].type != .routeEntry {
					break
				}
				
				prevIndex -= 1
			}
			
			if prevIndex >= 0 {
				loadCheckpointAtIndex(prevIndex, withAnimation: .fromLeft)
			} else {
				navigationController?.popViewController(animated: true)
			}
		} else if checkpointIndex == 0 {
			navigationController?.popViewController(animated: true)
		}
	}
	
	private func loadCheckpointAtIndex(_ index: Int, withAnimation animation: CheckpointAnimation = .none) {
		
		CheckpointManager.shared.addTrace("loadCheckpoint \(CheckpointManager.shared.keyForBlockIndex(blockIndex, stageIndex: stageIndex, checkpointIndex: index))")
		
		checkpointIndex = index
		
		switch animation {
		case .none:
			checkpointView = createCheckpointView(forType: checkpoints[checkpointIndex].type)
			populateCheckpointView(checkpointView, withCheckpointAtIndex: checkpointIndex)
			view.insertSubview(checkpointView, at: 0)
			
			currentXConstraint = checkpointView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
			NSLayoutConstraint.activate([
				checkpointView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.80),
				currentXConstraint,
				checkpointView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 16.0),
				checkpointView.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor, constant: -16.0)
			])
			
			loadNextCheckpointAfterIndex(checkpointIndex)
			loadPrevCheckpointBeforeIndex(checkpointIndex)
			
	// TODO: this is going away
		case .fromLeft, .fromRight:
			let newCheckpointView = createCheckpointView(forType: checkpoints[checkpointIndex].type)
			populateCheckpointView(newCheckpointView, withCheckpointAtIndex: checkpointIndex)
			view.insertSubview(newCheckpointView, at: 0)
			
			// offset new checkpoint view horizontally and then animate it into center postion
			let offset: CGFloat = (animation == .fromRight ? 400.0 : -400.0)
			let newCurrentXConstraint = newCheckpointView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: offset)
			NSLayoutConstraint.activate([
				newCheckpointView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.80),
				newCurrentXConstraint,
				newCheckpointView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 16.0),
				newCheckpointView.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor, constant: -48.0)
			])
			
			//newCheckpointView.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
			
			view.layoutIfNeeded()
			UIView.animate(withDuration: 0.3, animations: {
				self.currentXConstraint.constant = -offset
				newCurrentXConstraint.constant = 0.0
				newCheckpointView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
				self.view.layoutIfNeeded()
			}, completion: { (complete) in
				self.currentXConstraint = newCurrentXConstraint
				self.checkpointView.removeFromSuperview()
				self.checkpointView = newCheckpointView
				
				self.prevButton.isEnabled = true
				self.nextButton.isEnabled = true
			})
		}
		
		CheckpointManager.shared.markVisited(forBlock: blockIndex, stage: stageIndex, checkpoint: checkpointIndex)
		CheckpointManager.shared.persistState(forBlock: blockIndex, stage: stageIndex, checkpoint: checkpointIndex)
	}
	
	
	private let prevNextXFrameFactor: CGFloat = 0.84
	
	private func nextIndexAfterIndex(_ index: Int) -> Int? {
		
		var nextIndex = index + 1
		while nextIndex < checkpoints.count {
			
			if checkpoints[nextIndex].type == .routeEntry {
				
				var meetsCriteria = checkpoints[nextIndex].meetsCriteria
				
				if meetsCriteria {
					if let filename = checkpoints[nextIndex].routeFileName {
						CheckpointManager.shared.addTrace("nextCheckpoint does meet criteria for \(CheckpointManager.shared.keyForBlockIndex(blockIndex, stageIndex: stageIndex, checkpointIndex: nextIndex)), will route to \(filename)")
					} else {
						CheckpointManager.shared.addTrace("nextCheckpoint does meet criteria for \(CheckpointManager.shared.keyForBlockIndex(blockIndex, stageIndex: stageIndex, checkpointIndex: nextIndex)), but is MISSING a routeFileName for route checkpoint")
						meetsCriteria = false
					}
				} else {
					CheckpointManager.shared.addTrace("nextCheckpoint does NOT meet criteria for \(CheckpointManager.shared.keyForBlockIndex(blockIndex, stageIndex: stageIndex, checkpointIndex: nextIndex))")
				}
				
				if !meetsCriteria {
					
					// unmet criteria == visited
					CheckpointManager.shared.markVisited(forBlock: blockIndex, stage: stageIndex, checkpoint: nextIndex)
					
					// skip this checkpoint
					if nextIndex + 1 < checkpoints.count {
						nextIndex += 1
						continue
					} else {
						
						// ran out of checkpoints
						break
					}
				}
			}
			
			return nextIndex
		}
		
		return nil
	}
	
	private func loadNextCheckpointAfterIndex(_ index: Int) {
		
		if let nextCPV = nextCheckpointView {
			nextCPV.removeFromSuperview()
		}
		
		nextCheckpointView = nil
		nextXConstraint = nil

		nextXConstant = view.frame.width * prevNextXFrameFactor
		
		nextCheckpointIndex = nextIndexAfterIndex(index)
		if let nextIndex = nextCheckpointIndex {
			
			nextCheckpointView = createCheckpointView(forType: checkpoints[nextIndex].type)
			populateCheckpointView(nextCheckpointView!, withCheckpointAtIndex: nextIndex)
			view.insertSubview(nextCheckpointView!, at: 1)
			
			nextXConstraint = nextCheckpointView!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: nextXConstant)
			NSLayoutConstraint.activate([
				nextCheckpointView!.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.80),
				nextXConstraint!,
				nextCheckpointView!.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 16.0),
				nextCheckpointView!.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor, constant: -16.0)
			])
		}
	}
	
	private func prevIndexBeforeIndex(_ index: Int) -> Int? {
		
		// skip over route cps when going back (we skipped them going forward)
		var prevIndex = index - 1
		while prevIndex >= 0 {
			if checkpoints[prevIndex].type != .routeEntry {
				break
			}
			
			prevIndex -= 1
		}
		
		if prevIndex >= 0 {
			return prevIndex
		}
		
		return nil
	}
	
	private func loadPrevCheckpointBeforeIndex(_ index: Int) {
		
		if let prevCPV = prevCheckpointView {
			prevCPV.removeFromSuperview()
		}
		
		prevCheckpointView = nil
		prevXConstraint = nil
		
		prevXConstant = -view.frame.width * prevNextXFrameFactor
		
		prevCheckpointIndex = prevIndexBeforeIndex(index)
		if let prevIndex = prevCheckpointIndex {
			
			prevCheckpointView = createCheckpointView(forType: checkpoints[prevIndex].type)
			populateCheckpointView(prevCheckpointView!, withCheckpointAtIndex: prevIndex)
			view.insertSubview(prevCheckpointView!, at: 1)
			
			prevXConstraint = prevCheckpointView!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: prevXConstant)
			NSLayoutConstraint.activate([
				prevCheckpointView!.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.80),
				prevXConstraint!,
				prevCheckpointView!.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 16.0),
				prevCheckpointView!.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor, constant: -16.0)
			])
		}
	}
	
	private dynamic func handleLongPress(_ gr: UILongPressGestureRecognizer) {
		
		if gr.state != .began {
			return
		}
		
		if let hitView = view.hitTest(gr.location(ofTouch: 0, in: view), with: nil) {
			
			var hitKey: String? = nil
			switch checkpoints[checkpointIndex].type {
			case .infoEntry, .routeEntry, .nextStage:
				break
			
			case .fieldEntry:
				let fieldsCPView = checkpointView as! FieldsCheckpointView
				for (index, field) in fieldsCPView.textFields.enumerated() {
					if field == hitView {
						hitKey = checkpointView.keyForInstanceIndex(index)
					}
				}
			
			case .dateAndTextEntry,
			     .dateOnlyEntry:
				let datesCPView = checkpointView as! DatesCheckpointView
				for (index, field) in datesCPView.textFields.enumerated() {
					if field == hitView {
						hitKey = checkpointView.keyForInstanceIndex(index) + "_text"
					}
				}
				for (index, button) in datesCPView.dateButtons.enumerated() {
					if button == hitView {
						hitKey = checkpointView.keyForInstanceIndex(index) + "_date"
					}
				}
			
			case .checkboxEntry:
				let checkboxesCPView = checkpointView as! CheckboxesCheckpointView
				for (index, checkbox) in checkboxesCPView.checkboxes.enumerated() {
					if checkbox == hitView {
						hitKey = checkpointView.keyForInstanceIndex(index)
					}
				}
				
			case .radioEntry:
				let radiosCPView = checkpointView as! RadiosCheckpointView
				for (index, radio) in radiosCPView.radios.enumerated() {
					if radio == hitView {
						hitKey = checkpointView.keyForInstanceIndex(index)
					}
				}
			}
			
			if let hitKey = hitKey {
				let alert = UIAlertController(title: "Instance Key", message: hitKey, preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
				present(alert, animated: true, completion: nil)
			} else {
				
				hitKey = CheckpointManager.shared.keyForBlockIndex(blockIndex, stageIndex: stageIndex, checkpointIndex: checkpointIndex)
				
				let alert = UIAlertController(title: "Checkpoint Key", message: hitKey, preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
				alert.addAction(UIAlertAction(title: "Debug Info", style: .default, handler: { (action) in
					let traces = CheckpointManager.shared.allTraces()
					
					let mailComposerVC = MFMailComposeViewController()
					mailComposerVC.mailComposeDelegate = self
					mailComposerVC.setSubject("It's A Plan debug info")
					mailComposerVC.setMessageBody("Here is debug info for your session in the app:\n\n\(traces)", isHTML: false)
					
					self.present(mailComposerVC, animated: true, completion: nil)
				}))
				
				present(alert, animated: true, completion: nil)
			}
		}
	}
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true, completion: nil)
	}

}

class WebViewController: UIViewController, UIWebViewDelegate {
	
	var url = URL(string: "https://oregongoestocollege.org/5-things")
	
	@IBOutlet weak var webView: UIWebView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	var firstAppearance = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Information"
		
		if let ulr = url {
			let request = URLRequest(url: ulr)
			webView.loadRequest(request)
		}
		
		webView.delegate = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if firstAppearance {
			activityIndicator.startAnimating()
			firstAppearance = false
		}
	}
	
	private dynamic func goBack() {
		
		webView.goBack()
	}
	
	public func webViewDidFinishLoad(_ webView: UIWebView) {
		
		activityIndicator.stopAnimating()
		
		if webView.canGoBack {
			let backButton = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(goBack))
			navigationItem.leftBarButtonItem = backButton
		} else {
			navigationItem.leftBarButtonItem = nil
		}
	}
}
