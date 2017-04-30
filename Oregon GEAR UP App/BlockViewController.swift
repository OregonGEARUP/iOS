//
//  BlockViewController.swift
//  Oregon GEAR UP App
//
//  Created by Splonskowski, Splons on 2/28/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import UIKit

class BlockViewController: UIViewController {

	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var stackView: UIStackView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	private var firstAppearance = true
	
	var blockIndex = -1
	
    override func viewDidLoad() {
        super.viewDidLoad()

//		// load the JSON checkpoint information
//		activityIndicator.startAnimating()
//		CheckpointManager.shared.resumeCheckpoints { (success) in
//			
//			if success {
//				self.blockIndex = CheckpointManager.shared.blockIndex
//				let block = CheckpointManager.shared.blocks[self.blockIndex]
//				self.setupFor(block)
//				
//				self.activityIndicator.stopAnimating()
//				
//				if CheckpointManager.shared.stageIndex >= 0 && CheckpointManager.shared.checkpointIndex >= 0 {
//					self.showStage(forIndex: CheckpointManager.shared.stageIndex, checkpointIndex: CheckpointManager.shared.checkpointIndex, animated: false)
//				}
//				
//			} else {
//				// TODO: show error here?
//			}
//		}
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if firstAppearance {
			self.setupFor(CheckpointManager.shared.block)
			
			if CheckpointManager.shared.stageIndex >= 0 && CheckpointManager.shared.checkpointIndex >= 0 {
				self.showStage(forIndex: CheckpointManager.shared.stageIndex, checkpointIndex: CheckpointManager.shared.checkpointIndex, animated: false)
			}
		} else {
			CheckpointManager.shared.persistState(forBlock: blockIndex, stage: -1, checkpoint: -1)
		}
		
		firstAppearance = false
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	dynamic func handleStageTap(_ button: UIButton) {
		
		showStage(forIndex: button.tag, checkpointIndex: 0)
	}
	
	private func showStage(forIndex index: Int, checkpointIndex: Int, animated: Bool = true) {
		
		let vc: StageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "stage") as! StageViewController
		vc.blockIndex = blockIndex
		vc.stageIndex = index
		vc.checkpointIndex = checkpointIndex
		navigationController?.pushViewController(vc, animated: animated)
	}
	
	private func prepareForNewBlock() {
		
		for view in stackView.arrangedSubviews {
			view.removeFromSuperview()
		}
	}
	
	private func setupFor(_ block: Block) {
		
		prepareForNewBlock()

		title = block.title
		
		self.blockIndex = CheckpointManager.shared.blockIndex
		
		for (index, stage) in block.stages.enumerated() {
			
			let button = UIButton(type: .custom)
			button.tag = index
			button.setTitle(stage.title, for: .normal)
			button.addTarget(self, action: #selector(self.handleStageTap(_:)), for: .touchUpInside)
			
			button.titleLabel?.font = UIFont.systemFont(ofSize: 22.0)
			button.titleLabel?.numberOfLines = 0
			button.titleLabel?.textAlignment = .center
			button.setTitleColor(.gray, for: .normal)
			button.setTitleColor(.lightGray, for: .highlighted)
			
			button.layer.cornerRadius = 5.0
			button.layer.backgroundColor = UIColor.cyan.withAlphaComponent(0.3).cgColor
			
			stackView.addArrangedSubview(button)
			
			button.widthAnchor.constraint(equalTo: self.stackView.widthAnchor, multiplier: 0.8).isActive = true
			button.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
		}
	}
	
	@IBAction func unwindToNewBlock(unwindSegue: UIStoryboardSegue) {
		
		guard unwindSegue.identifier == "unwindToNewBlock" else {
			return
		}
		
		guard let stageViewController = unwindSegue.source as? StageViewController else {
			return
		}
		
		guard let blockFilename = stageViewController.routeFilename else {
			return
		}
		
		print("unwindToNewBlock: \(blockFilename)")
		
		prepareForNewBlock()
		activityIndicator.startAnimating()
		
		CheckpointManager.shared.loadNextBlock(fromFile: blockFilename) { (success) in
			
			if success {
				self.setupFor(CheckpointManager.shared.block)
				
				self.activityIndicator.stopAnimating()
				
			} else {
				// TODO: show error here?
			}
		}

	}
}
