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
	
	var blockIndex = 0		// TODO: need to set this programatically
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// load the JSON checkpoint information
		CheckpointManager.shared.fetchCheckpoints() { (success) in
			
			if success {
				let block = CheckpointManager.shared.blocks[self.blockIndex]
				
				self.title = block.title
				
				for (index, stage) in block.stages.enumerated() {
					
					let button = UIButton(type: .custom)
					button.tag = index
					button.setTitle(stage.title, for: .normal)
					button.addTarget(self, action: #selector(self.handleStageTap(_:)), for: .touchUpInside)
					
					button.titleLabel?.font = UIFont.systemFont(ofSize: 24.0)
					button.setTitleColor(.gray, for: .normal)
					button.setTitleColor(.lightGray, for: .highlighted)
					
					button.layer.cornerRadius = 5.0
					button.layer.backgroundColor = UIColor.cyan.withAlphaComponent(0.3).cgColor
					
					self.stackView.addArrangedSubview(button)

					button.widthAnchor.constraint(equalTo: self.stackView.widthAnchor, multiplier: 0.8).isActive = true
					button.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
				}
				
			} else {
				// TODO: show error here?
			}
		}
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	dynamic func handleStageTap(_ button: UIButton) {
		
		let vc: StageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "stage") as! StageViewController
//		let vc: NewStageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "newstage") as! NewStageViewController
		vc.blockIndex = 0
		vc.stageIndex = button.tag
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
}
