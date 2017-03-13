//
//  NewStageViewController.swift
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
}

class CheckboxesCheckpointView: CheckpointView {
	public let checkboxes = [UIButton(), UIButton(), UIButton()]
}

class RadiosCheckpointView: CheckpointView {
	public let radios = [UIButton(), UIButton(), UIButton()]
}


class NewStageViewController: UIViewController {

	var blockIndex = 0
	var stageIndex = 0
	var checkpointIndex = 0
	
	@IBOutlet var cpContainerView: UIView!
	var cpView: CheckpointView!
	
	private var checkpoints: [Checkpoint] {
		return CheckpointManager.shared.blocks[blockIndex].stages[stageIndex].checkpoints
	}
	
	private func keyForInstanceIndex(_ instanceIndex: Int) -> String {
		return CheckpointManager.shared.keyForBlockIndex(blockIndex, stageIndex: stageIndex, checkpointIndex: checkpointIndex, instanceIndex: instanceIndex)
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		cpContainerView.backgroundColor = .clear
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		title = CheckpointManager.shared.blocks[blockIndex].stages[stageIndex].title
		
		cpView = createCheckpointView(forType: checkpoints[checkpointIndex].type)
		cpContainerView.addSubview(cpView)
		NSLayoutConstraint.activate([
			cpView.leftAnchor.constraint(equalTo: cpContainerView.leftAnchor),
			cpView.rightAnchor.constraint(equalTo: cpContainerView.rightAnchor),
			cpView.topAnchor.constraint(equalTo: cpContainerView.topAnchor),
			cpView.bottomAnchor.constraint(equalTo: cpContainerView.bottomAnchor)
		])
		
		populateCheckpointView(cpView, with: checkpoints[checkpointIndex])
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
		case .fieldDateEntry:
			cpView = DatesCheckpointView()
		case .checkboxEntry:
			cpView = CheckboxesCheckpointView()
		case .radioEntry:
			cpView = RadiosCheckpointView()
		}
		
		cpView.layer.backgroundColor = UIColor(white: 0.95, alpha: 1.0).cgColor
		cpView.layer.borderColor = UIColor.lightGray.cgColor
		cpView.layer.borderWidth = 0.5
		cpView.layer.cornerRadius = 5.0
		
		cpView.translatesAutoresizingMaskIntoConstraints = false
		
		cpView.titleLabel.translatesAutoresizingMaskIntoConstraints = false
		cpView.titleLabel.font = UIFont.boldSystemFont(ofSize: 19.0)
		cpView.titleLabel.textAlignment = .center
		cpView.titleLabel.numberOfLines = 1
		cpView.addSubview(cpView.titleLabel)
		NSLayoutConstraint.activate([
			cpView.titleLabel.topAnchor.constraint(equalTo: cpView.topAnchor, constant: 18.0),
			cpView.titleLabel.leadingAnchor.constraint(equalTo: cpView.leadingAnchor, constant: 8.0),
			cpView.titleLabel.trailingAnchor.constraint(equalTo: cpView.trailingAnchor, constant: -8.0)
		])
		
		cpView.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		cpView.descriptionLabel.font = UIFont.systemFont(ofSize: 16.0)
		cpView.descriptionLabel.textAlignment = .left
		cpView.descriptionLabel.numberOfLines = 0
		cpView.addSubview(cpView.descriptionLabel)
		NSLayoutConstraint.activate([
			cpView.descriptionLabel.topAnchor.constraint(equalTo: cpView.titleLabel.bottomAnchor, constant: 8.0),
			cpView.descriptionLabel.leadingAnchor.constraint(equalTo: cpView.leadingAnchor, constant: 8.0),
			cpView.descriptionLabel.trailingAnchor.constraint(equalTo: cpView.trailingAnchor, constant: -8.0)
		])
		
		cpView.moreInfoButton.translatesAutoresizingMaskIntoConstraints = false
		cpView.moreInfoButton.addTarget(self, action: #selector(showMoreInfo), for: .touchUpInside)
		cpView.addSubview(cpView.moreInfoButton)
		NSLayoutConstraint.activate([
			cpView.moreInfoButton.topAnchor.constraint(equalTo: cpView.descriptionLabel.bottomAnchor, constant: 8.0),
			cpView.moreInfoButton.leadingAnchor.constraint(equalTo: cpView.leadingAnchor, constant: 8.0),
		])
		
		cpView.stackView.translatesAutoresizingMaskIntoConstraints = false
		cpView.stackView.axis = .vertical
		cpView.stackView.alignment = .fill
		cpView.stackView.distribution = .fill
		cpView.stackView.spacing = 3.0
		cpView.addSubview(cpView.stackView)
		NSLayoutConstraint.activate([
			cpView.stackView.topAnchor.constraint(equalTo: cpView.moreInfoButton.bottomAnchor, constant: 16.0),
			cpView.stackView.leadingAnchor.constraint(equalTo: cpView.leadingAnchor, constant: 8.0),
			cpView.stackView.trailingAnchor.constraint(equalTo: cpView.trailingAnchor, constant: -8.0)
		])
		
		switch type {
		case .infoEntry:
			break
			
		case .fieldEntry:
			let fieldsCPView = cpView as! FieldsCheckpointView
			for i in 0..<cpView.maxInstances {
				fieldsCPView.fieldLabels[i].translatesAutoresizingMaskIntoConstraints = false
				fieldsCPView.fieldLabels[i].font = UIFont.systemFont(ofSize: 16.0)
				fieldsCPView.fieldLabels[i].textAlignment = .left
				fieldsCPView.fieldLabels[i].numberOfLines = 1
				cpView.stackView.addArrangedSubview(fieldsCPView.fieldLabels[i])
				
				fieldsCPView.textFields[i].translatesAutoresizingMaskIntoConstraints = false
				fieldsCPView.textFields[i].borderStyle = .roundedRect
				cpView.stackView.addArrangedSubview(fieldsCPView.textFields[i])
				
				let spacer = UIView()
				cpView.stackView.addArrangedSubview(spacer)
				let hc2 = spacer.heightAnchor.constraint(equalToConstant: 8.0)
				hc2.priority = UILayoutPriorityRequired - 1
				hc2.isActive = true
			}
			
		case .fieldDateEntry:
			let datesCPView = cpView as! DatesCheckpointView
			for i in 0..<cpView.maxInstances {
				datesCPView.fieldLabels[i].translatesAutoresizingMaskIntoConstraints = false
				datesCPView.fieldLabels[i].font = UIFont.systemFont(ofSize: 16.0)
				datesCPView.fieldLabels[i].textAlignment = .left
				datesCPView.fieldLabels[i].numberOfLines = 1
				cpView.stackView.addArrangedSubview(datesCPView.fieldLabels[i])
				
				datesCPView.textFields[i].translatesAutoresizingMaskIntoConstraints = false
				datesCPView.textFields[i].borderStyle = .roundedRect
				cpView.stackView.addArrangedSubview(datesCPView.textFields[i])
				
				datesCPView.dateButtons[i].translatesAutoresizingMaskIntoConstraints = false
				datesCPView.dateButtons[i].contentHorizontalAlignment = .left
				datesCPView.dateButtons[i].contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
				datesCPView.dateButtons[i].layer.backgroundColor = UIColor.white.cgColor
				datesCPView.dateButtons[i].layer.borderColor = UIColor(white: 0.8, alpha: 1.0).cgColor
				datesCPView.dateButtons[i].layer.borderWidth = 0.5
				datesCPView.dateButtons[i].layer.cornerRadius = 5.0
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
				radiosCPView.radios[i].addTarget(self, action: #selector(handleRadio(_:)), for: .touchUpInside)
				cpView.stackView.addArrangedSubview(radiosCPView.radios[i])
			}
		}
		
		return cpView
	}
	
	private func populateCheckpointView(_ cpView: CheckpointView, with checkPoint: Checkpoint) {
		
		cpView.titleLabel.text = checkPoint.title
		cpView.descriptionLabel.text = checkPoint.description
		
		if let url = checkPoint.moreInfoURL {
			if let linkText = checkPoint.moreInfo {
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
		case .infoEntry:
			break
			
		case .fieldEntry:
			let fieldsCPView = cpView as! FieldsCheckpointView
			for i in 0..<cpView.maxInstances {
				if (i < checkPoint.instances.count) {
					fieldsCPView.fieldLabels[i].isHidden = false
					fieldsCPView.textFields[i].isHidden = false
					fieldsCPView.fieldLabels[i].text = checkPoint.instances[i].prompt
					fieldsCPView.textFields[i].text = defaults.string(forKey: keyForInstanceIndex(i+1))
				} else {
					fieldsCPView.fieldLabels[i].isHidden = true
					fieldsCPView.textFields[i].isHidden = true
				}
			}
		
		case .fieldDateEntry:
			let datesCPView = cpView as! DatesCheckpointView
			for i in 0..<cpView.maxInstances {
				if (i < checkPoint.instances.count) {
					datesCPView.fieldLabels[i].isHidden = false
					datesCPView.textFields[i].isHidden = false
					datesCPView.dateButtons[i].isHidden = false
					datesCPView.fieldLabels[i].text = checkPoint.instances[i].prompt
					
					let key = keyForInstanceIndex(i+1)
					datesCPView.textFields[i].text = defaults.string(forKey: "\(key)_field")
					datesCPView.dateButtons[i].setTitle(defaults.string(forKey: "\(key)_date"), for: .normal)
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
					checkboxesCPView.checkboxes[i].setTitle(checkPoint.instances[i].prompt, for: .normal)
					checkboxesCPView.checkboxes[i].isSelected = defaults.bool(forKey: keyForInstanceIndex(i+1))
				} else {
					checkboxesCPView.checkboxes[i].isHidden = true
				}
			}
		
		case .radioEntry:
			let radiosCPView = cpView as! RadiosCheckpointView
			for i in 0..<cpView.maxInstances {
				if (i < checkPoint.instances.count) {
					radiosCPView.radios[i].isHidden = false
					radiosCPView.radios[i].setTitle(checkPoint.instances[i].prompt, for: .normal)
					radiosCPView.radios[i].isSelected = defaults.bool(forKey: keyForInstanceIndex(i+1))
				} else {
					radiosCPView.radios[i].isHidden = true
				}
			}
		}
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
		
		let radiosCPView = cpView as! RadiosCheckpointView
		for radio in radiosCPView.radios {
			radio.isSelected = false
		}
		
		sender.isSelected = true
	}


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
