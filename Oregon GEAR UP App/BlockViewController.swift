//
//  BlockViewController.swift
//  Oregon GEAR UP App
//
//  Created by Splonskowski, Splons on 2/28/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import UIKit

class BlockViewController: UIViewController {
	
	let buttonTagOffset = 100
	let statusTagOffset = 200

	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var stackView: UIStackView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	private let completeButtonColor = UIColor(red: 0x8c/255.0, green: 0xc6/255.0, blue: 0x3f/255.0, alpha: 1.0)
	private let inprogressButtonColor = UIColor(red: 0x00/255.0, green: 0xae/255.0, blue: 0xef/255.0, alpha: 1.0)
	
	private var firstAppearance = true
	
	var blockIndex = -1
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
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
		
		showStage(forIndex: button.tag - buttonTagOffset, checkpointIndex: 0)
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

		blockIndex = CheckpointManager.shared.blockIndex
		title = "\(blockIndex+1). \(block.title)"
		
		for (index, stage) in block.stages.enumerated() {
			
			let button = UIButton(type: .custom)
			button.tag = buttonTagOffset + index
			button.setTitle(stage.title, for: .normal)
			button.addTarget(self, action: #selector(self.handleStageTap(_:)), for: .touchUpInside)
			
			button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 40)
			button.contentHorizontalAlignment = .left
			
			button.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
			button.titleLabel?.numberOfLines = 0
			button.setTitleColor(.white, for: .normal)
			button.setTitleColor(.lightGray, for: .highlighted)
			
			button.layer.cornerRadius = 5.0
			button.layer.backgroundColor = completeButtonColor.cgColor
			
			stackView.addArrangedSubview(button)
			
			button.widthAnchor.constraint(equalTo: self.stackView.widthAnchor, multiplier: 0.8).isActive = true
			button.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
			
			
			let statusView = UIImageView()
			statusView.translatesAutoresizingMaskIntoConstraints = false
			statusView.contentMode = .scaleAspectFit
			statusView.tag = statusTagOffset + index
			statusView.image = UIImage(named: "checkmark_big")!.withRenderingMode(.alwaysTemplate)
			statusView.tintColor = .white
			statusView.alpha = 0.0
			button.addSubview(statusView)
			
			statusView.widthAnchor.constraint(equalToConstant: 45.0).isActive = true
			statusView.heightAnchor.constraint(equalToConstant: 45.0).isActive = true
			statusView.rightAnchor.constraint(equalTo: button.rightAnchor, constant: -10.0).isActive = true
			statusView.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
		}
	}
	
	private func updateForBlock(_ block: Block) {
		
		// show checkmarks for completed stages
		for (index, _) in block.stages.enumerated() {
			
			let completed = CheckpointManager.shared.stageCompleted(atIndex: index)
			
			if let button = view.viewWithTag(buttonTagOffset + index) as? UIButton {
				button.layer.backgroundColor = completed ? completeButtonColor.cgColor : inprogressButtonColor.cgColor
			}
			
			if let statusView = view.viewWithTag(statusTagOffset + index) {
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
