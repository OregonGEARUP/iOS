//
//  OverviewViewController.swift
//  Oregon GEAR UP App
//
//  Created by Splonskowski, Splons on 4/30/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import UIKit

class OverviewViewController: UIViewController {
	
	@IBOutlet weak var welcomeOverlay: UIView!

	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var stackView: UIStackView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	let buttonColor = UIColor(red: 0x00/255.0, green: 0xae/255.0, blue: 0xef/255.0, alpha: 1.0)
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = NSLocalizedString("It's A Plan!", comment: "overview title")
		
		welcomeOverlay.alpha = 0.0
		welcomeOverlay.layer.borderColor = UIColor.lightGray.cgColor
		welcomeOverlay.layer.borderWidth = 0.5
		welcomeOverlay.layer.cornerRadius = 5.0
		
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
		
		update()
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
			
			button.titleLabel?.font = UIFont.systemFont(ofSize: 22.0)
			button.titleLabel?.numberOfLines = 0
			button.titleLabel?.textAlignment = .center
			button.setTitleColor(.white, for: .normal)
			button.setTitleColor(.lightGray, for: .highlighted)
			
			button.layer.cornerRadius = 5.0
			button.layer.backgroundColor = buttonColor.withAlphaComponent(button.isEnabled ? 0.5 : 0.1).cgColor
			
			stackView.addArrangedSubview(button)
			
			button.widthAnchor.constraint(equalTo: self.stackView.widthAnchor, multiplier: 0.8).isActive = true
			button.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
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
				button.layer.backgroundColor = buttonColor.withAlphaComponent(button.isEnabled ? 0.5 : 0.1).cgColor
			}
		}
	}
	
	private func showWelcomeOverlay() {
		
		UIView.animate(withDuration: 0.3) {
			self.welcomeOverlay.alpha = 1.0
		}
	}
	
	@IBAction private func dismissWelcomeOverlay() {
		
//		if CheckpointManager.shared.blockIndex >= 0 {
//			self.showBlock(forIndex: CheckpointManager.shared.blockIndex, stageIndex: CheckpointManager.shared.stageIndex, checkpointIndex: CheckpointManager.shared.checkpointIndex, animated: true)
//		}
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { 
			self.welcomeOverlay.alpha = 0.0
			self.scrollView.alpha = 1.0
		}
	}
}
