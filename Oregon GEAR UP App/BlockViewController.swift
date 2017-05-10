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
	
	let buttonColor = UIColor(red: 0xc8/255.0, green: 0xf0/255.0, blue: 0xf8/255.0, alpha: 1.0)
	
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
//				self.setupForBlock(block)
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
			self.setupForBlock(CheckpointManager.shared.block)
			
			if CheckpointManager.shared.stageIndex >= 0 && CheckpointManager.shared.checkpointIndex >= 0 {
				self.showStage(forIndex: CheckpointManager.shared.stageIndex, checkpointIndex: CheckpointManager.shared.checkpointIndex, animated: false)
			}
		} else {
			CheckpointManager.shared.persistState(forBlock: blockIndex, stage: -1, checkpoint: -1)
		}
		
		updateForBlock(CheckpointManager.shared.block)
		
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
	
	private func setupForBlock(_ block: Block) {
		
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
			button.setTitleColor(.darkText, for: .normal)
			button.setTitleColor(.lightGray, for: .highlighted)
			
			button.layer.cornerRadius = 5.0
			button.layer.backgroundColor = buttonColor.cgColor
			
			stackView.addArrangedSubview(button)
			
			button.widthAnchor.constraint(equalTo: self.stackView.widthAnchor, multiplier: 0.8).isActive = true
			button.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
			
			
			let statusView = UIImageView()
			statusView.translatesAutoresizingMaskIntoConstraints = false
			statusView.contentMode = .scaleAspectFit
			statusView.tag = 100 + index
			statusView.image = UIImage(named: "tab_checkpoints")!.withRenderingMode(.alwaysTemplate)
			statusView.tintColor = .gray
			statusView.alpha = 0.0
			button.addSubview(statusView)
			
			statusView.widthAnchor.constraint(equalToConstant: 18.0).isActive = true
			statusView.heightAnchor.constraint(equalToConstant: 18.0).isActive = true
			statusView.rightAnchor.constraint(equalTo: button.rightAnchor, constant: -6.0).isActive = true
			statusView.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -6.0).isActive = true
		}
	}
	
	private func updateForBlock(_ block: Block) {
		
		// show checkmarks for completed stages
		for (index, _) in block.stages.enumerated() {
			
			let completed = CheckpointManager.shared.stageCompleted(atIndex: index)
			
			if let statusView = view.viewWithTag(100 + index) {
				statusView.alpha = completed ? 1.0 : 0.0
			}
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
				self.setupForBlock(CheckpointManager.shared.block)
				self.updateForBlock(CheckpointManager.shared.block)
				
				self.activityIndicator.stopAnimating()
				
			} else {
				// TODO: show error here?
			}
		}

	}
}
