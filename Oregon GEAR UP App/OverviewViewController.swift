//
//  OverviewViewController.swift
//  Oregon GEAR UP App
//
//  Created by Splonskowski, Splons on 4/30/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import UIKit
import UserNotifications


class OverviewViewController: UIViewController, UIScrollViewDelegate {
	
	let completedTagOffset = 200
	let progressTagOffset = 300
	let progress2TagOffset = 400
	
	var blockToShow = -1
	var verticalScrollOffset: CGFloat = -64.0
	
	@IBOutlet weak var welcomeOverlay: UIView!
	@IBOutlet weak var welcome1Label: UILabel!
	@IBOutlet weak var welcome2Label: UILabel!
	@IBOutlet var numberLabels: [UILabel]!
	@IBOutlet var numberLabelCenterX: [NSLayoutConstraint]!
	@IBOutlet weak var getStartedButton: UIButton!

	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var stackView: UIStackView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	private var firstAppearance = true

    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = NSLocalizedString("Checklist", comment: "overview title")
		
		StyleGuide.addGradientLayerTo(view)
		
		let smallerScreen = UIScreen.main.bounds.height <= 568.0
		let plusScreen = UIScreen.main.bounds.height > 667.0
		
		welcomeOverlay.alpha = 0.0
		welcomeOverlay.layer.borderColor = UIColor.lightGray.cgColor
		welcomeOverlay.layer.borderWidth = 0.5
		welcomeOverlay.layer.cornerRadius = 5.0
		
		welcome1Label.textColor = StyleGuide.completeButtonColor
		
		if smallerScreen {
			welcome1Label.font = UIFont.systemFont(ofSize: 17.0, weight: UIFontWeightMedium)
			welcome2Label.font = UIFont.systemFont(ofSize: 15.0, weight: UIFontWeightMedium)
		}
		
		// change "10" to green text
		if let text = welcome2Label.text {
			let attrWelcome = NSMutableAttributedString(string: text)
			let r = (text as NSString).range(of: "10")
			if r.location != NSNotFound {
				attrWelcome.setAttributes([NSForegroundColorAttributeName: StyleGuide.completeButtonColor], range: r)
			}
			welcome2Label.attributedText = attrWelcome
		}
		
		// setup the numerals to be green and hidden
		let baseSize: CGFloat = smallerScreen ? 25.0 : plusScreen ? 41.0 : 34.0
		for (index, label) in numberLabels.enumerated() {
			label.textColor = StyleGuide.completeButtonColor
			label.font = UIFont.boldSystemFont(ofSize: baseSize + CGFloat(index))
			label.alpha = 0.0
		}
		
		// setup the horizontal constraints of the numerals
		var offset: CGFloat = -12.0
		for constraint in numberLabelCenterX {
			constraint.constant = offset
			offset = offset * -1.0
		}
		
		getStartedButton.layer.cornerRadius = 4.0
		getStartedButton.layer.backgroundColor = StyleGuide.completeButtonColor.cgColor
		getStartedButton.setTitleColor(.white, for: .normal)
		getStartedButton.alpha = 0.0
		
		scrollView.delegate = self
		
		
		// load the JSON checkpoint information
		activityIndicator.startAnimating()
		CheckpointManager.shared.resumeCheckpoints { (success) in
			
			if success {
				self.setup()
				
				self.activityIndicator.stopAnimating()
				
				// show welcome message if first run
				if UserDefaults.standard.bool(forKey: "welcomedone") == false {
					self.scrollView.alpha = 0.2
					self.showWelcomeOverlay()
					UserDefaults.standard.set(true, forKey: "welcomedone")
				} else {
					if CheckpointManager.shared.blockIndex >= 0 {
						self.showBlock(forIndex: CheckpointManager.shared.blockIndex, stageIndex: CheckpointManager.shared.stageIndex, checkpointIndex: CheckpointManager.shared.checkpointIndex, animated: false)
					}
				}
			} else {
				// TODO: show error here?
			}
		}
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		blockToShow = CheckpointManager.shared.blockIndex
		
		if firstAppearance {
			
		} else {
			CheckpointManager.shared.persistBlockCompletionInfo()
			CheckpointManager.shared.persistState(forBlock: -1, stage: -1, checkpoint: -1)
		}
		
		update()
		
		firstAppearance = false
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		scrollView.contentOffset = CGPoint(x: 0.0, y: verticalScrollOffset)
		
//		// show either the top half or the bottom half
//		if blockToShow < 5 {
//			scrollView.setContentOffset(CGPoint(x: 0, y: -64.0), animated: false)
//		} else {
//			let offset = scrollView.contentSize.height - scrollView.frame.height + 64.0 /*- 150.0*/
//			scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
//		}
		
		if #available(iOS 10.0, *) {
			UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
				if !granted {
					print("user denied notifications")
				}
			}
		}
	}
	
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		verticalScrollOffset = scrollView.contentOffset.y
	}
	
	dynamic func handleBlockTap(_ button: UIButton) {
		
		showBlock(forIndex: button.tag, stageIndex: -1, checkpointIndex: -1)
	}
	
	private func showBlock(forIndex index: Int, stageIndex: Int, checkpointIndex: Int, animated: Bool = true) {
		
		activityIndicator.startAnimating()
		
		CheckpointManager.shared.loadBlock(atIndex: index) { (success) in
			
			if success {
				self.activityIndicator.stopAnimating()
				let vc: BlockViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "block") as! BlockViewController
				vc.blockIndex = index
				self.navigationController?.pushViewController(vc, animated: animated)
			}
		}
	}
	
	private func prepareForNewBlocks() {
		
		for view in stackView.arrangedSubviews {
			view.removeFromSuperview()
		}
	}
	
	private func setup() {
		
		prepareForNewBlocks()
		
		for index in 0..<CheckpointManager.shared.countOfBlocks() {
			
			let blockInfo = CheckpointManager.shared.blockInfo(forIndex: index)
			
			let button = UIButton(type: .custom)
			button.tag = index
			button.setTitle("\(index+1). \(blockInfo.title)", for: .normal)
			button.addTarget(self, action: #selector(self.handleBlockTap(_:)), for: .touchUpInside)
			button.isEnabled = blockInfo.available
			
			button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 40)
			button.contentHorizontalAlignment = .left
			
			button.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
			button.titleLabel?.numberOfLines = 0
			button.setTitleColor(.white, for: .normal)
			button.setTitleColor(.lightGray, for: .highlighted)
			button.setTitleColor(.lightGray, for: .disabled)
			
			button.layer.cornerRadius = 5.0
			button.layer.backgroundColor = button.isEnabled ? StyleGuide.inprogressButtonColor.cgColor : StyleGuide.inactiveButtonColor.cgColor
			
			stackView.addArrangedSubview(button)
			
			button.widthAnchor.constraint(equalTo: self.stackView.widthAnchor, multiplier: 0.8).isActive = true
			button.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
			
			
			let completedView = UIImageView()
			completedView.translatesAutoresizingMaskIntoConstraints = false
			completedView.contentMode = .scaleAspectFit
			completedView.tag = completedTagOffset + index
			completedView.image = UIImage(named: "checkmark_big")!.withRenderingMode(.alwaysTemplate)
			completedView.tintColor = .white
			completedView.alpha = 0.0
			button.addSubview(completedView)
			
			completedView.widthAnchor.constraint(equalToConstant: 45.0).isActive = true
			completedView.heightAnchor.constraint(equalToConstant: 45.0).isActive = true
			completedView.rightAnchor.constraint(equalTo: button.rightAnchor, constant: -10.0).isActive = true
			completedView.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
			
			
			let progressLabel = UILabel()
			progressLabel.translatesAutoresizingMaskIntoConstraints = false
			progressLabel.tag = progressTagOffset + index
			progressLabel.font = UIFont.systemFont(ofSize: 17.0, weight: UIFontWeightSemibold)
			progressLabel.textColor = .white
			progressLabel.alpha = 0.0
			button.addSubview(progressLabel)
			
			progressLabel.rightAnchor.constraint(equalTo: button.rightAnchor, constant: -12.0).isActive = true
			progressLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor, constant: -4.0).isActive = true
			
			let progress2Label = UILabel()
			progress2Label.translatesAutoresizingMaskIntoConstraints = false
			progress2Label.text = "completed"
			progress2Label.tag = progress2TagOffset + index
			progress2Label.font = UIFont.systemFont(ofSize: 10.0, weight: UIFontWeightRegular)
			progress2Label.textColor = .white
			progress2Label.alpha = 0.0
			button.addSubview(progress2Label)
			
			progress2Label.centerXAnchor.constraint(equalTo: progressLabel.centerXAnchor).isActive = true
			progress2Label.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 0.0).isActive = true
		}
		
		// add in label with app version info
		if let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName"),
			let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString"),
			let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") {
			
			let spacer = UIView()
			stackView.addArrangedSubview(spacer)
			spacer.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
			spacer.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
			
			let versionLabel = UILabel()
			versionLabel.text = "\(name), v\(version) (\(build))\n\nOregon GEAR UP"
			versionLabel.numberOfLines = 0
			versionLabel.textAlignment = .center
			versionLabel.textColor = .gray
			versionLabel.font = UIFont.systemFont(ofSize: 13.0, weight: UIFontWeightThin)
			stackView.addArrangedSubview(versionLabel)
		}
	}
	
	private func update() {
		
		let blockCount = CheckpointManager.shared.countOfBlocks()
		for (index, button) in stackView.arrangedSubviews.enumerated() {
			if let button = button as? UIButton {
				
				if index >= blockCount {
					break
				}
				
				let blockInfo = CheckpointManager.shared.blockInfo(forIndex: index)
				button.setTitle("\(index+1). \(blockInfo.title)", for: .normal)
				button.isEnabled = blockInfo.available
				
				let completedView = view.viewWithTag(index + completedTagOffset)
				let progressLabel = view.viewWithTag(index + progressTagOffset) as? UILabel
				let progress2Label = view.viewWithTag(index + progress2TagOffset) as? UILabel
				
				completedView?.alpha = 0.0
				progressLabel?.alpha = 0.0
				progress2Label?.alpha = 0.0
				
				if button.isEnabled {
					
					if blockInfo.done {
						button.layer.backgroundColor = StyleGuide.completeButtonColor.cgColor
						completedView?.alpha = 1.0
					} else {
						button.layer.backgroundColor = StyleGuide.inprogressButtonColor.cgColor
						
						if let completed = blockInfo.stagesComplete, let total = blockInfo.stageCount {
							progressLabel?.text = "\(completed) / \(total)"
							progressLabel?.text = "\(completed) of \(total)"
							progressLabel?.alpha = 1.0
							progress2Label?.alpha = 1.0
						}
						
						if firstAppearance && blockToShow < 0 {
							blockToShow = index
						}
					}
				} else {
					button.layer.backgroundColor = StyleGuide.inactiveButtonColor.cgColor
				}
			}
		}
	}
	
	private func showWelcomeOverlay() {
		
		UIView.animate(withDuration: 0.3, animations: {
			self.welcomeOverlay.alpha = 1.0
		}) { (finished) in
			self.showNumberLabel(atIndex: 0)
		}
	}
	
	private func showNumberLabel(atIndex index: Int) {
		
		if index < numberLabels.count {
			
			UIView.animate(withDuration: 0.07, animations: {
				self.numberLabels[index].alpha = 1.0 - CGFloat(index) * 0.1
			}, completion: { (finished) in
				self.showNumberLabel(atIndex: index+1)
			})
		} else {
			UIView.animate(withDuration: 0.2) {
				self.getStartedButton.alpha = 1.0
			}
		}
	}
	
	@IBAction private func dismissWelcomeOverlay() {
		
		UIView.animate(withDuration: 0.3) {
			self.welcomeOverlay.alpha = 0.0
			self.scrollView.alpha = 1.0
		}
	}
}
