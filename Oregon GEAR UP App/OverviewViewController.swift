//
//  OverviewViewController.swift
//  Oregon GEAR UP App
//
//  Created by Splonskowski, Splons on 4/30/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import UIKit

class OverviewViewController: UIViewController {

	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var stackView: UIStackView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = NSLocalizedString("It's A Plan!", comment: "overview title")

		// load the JSON checkpoint information
		activityIndicator.startAnimating()
		CheckpointManager.shared.resumeCheckpoints { (success) in
			
			if success {
				self.setup()
				
				self.activityIndicator.stopAnimating()
				
				if CheckpointManager.shared.blockIndex >= 0 {
					self.showBlock(forIndex: CheckpointManager.shared.blockIndex, stageIndex: CheckpointManager.shared.stageIndex, checkpointIndex: CheckpointManager.shared.checkpointIndex, animated: false)
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

		for (index, blockInfo) in CheckpointManager.shared.blockInfo.enumerated() {
			
			let button = UIButton(type: .custom)
			button.tag = index
			button.setTitle(blockInfo["title"] as? String, for: .normal)
			button.addTarget(self, action: #selector(self.handleBlockTap(_:)), for: .touchUpInside)
			
			if let filename = blockInfo["blockFileName"] as? String {
				button.isEnabled = !filename.isEmpty
			} else {
				button.isEnabled = false
			}
			
			button.titleLabel?.font = UIFont.systemFont(ofSize: 22.0)
			button.titleLabel?.numberOfLines = 0
			button.titleLabel?.textAlignment = .center
			button.setTitleColor(.gray, for: .normal)
			button.setTitleColor(.lightGray, for: .highlighted)
			
			button.layer.cornerRadius = 5.0
			button.layer.backgroundColor = UIColor.green.withAlphaComponent(button.isEnabled ? 0.5 : 0.1).cgColor
			
			stackView.addArrangedSubview(button)
			
			button.widthAnchor.constraint(equalTo: self.stackView.widthAnchor, multiplier: 0.8).isActive = true
			button.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
		}
	}
	
	private func update() {
		
		for (index, button) in stackView.arrangedSubviews.enumerated() {
			if let button = button as? UIButton {
				
				if index >= CheckpointManager.shared.blockInfo.count {
					break
				}
				
				let blockInfo = CheckpointManager.shared.blockInfo[index]
				button.setTitle(blockInfo["title"] as? String, for: .normal)
				if let filename = blockInfo["blockFileName"] as? String {
					button.isEnabled = !filename.isEmpty
				} else {
					button.isEnabled = false
				}
				button.layer.backgroundColor = UIColor.green.withAlphaComponent(button.isEnabled ? 0.5 : 0.1).cgColor
			}
		}
	}
}
