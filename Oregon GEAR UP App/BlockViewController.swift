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
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// load the JSON checkpoint information
		CheckpointManager.shared.fetchCheckpoints() { (success) in
			
			if success {
				self.title = CheckpointManager.shared.blocks[0].title
				
				
				// TODO: need to build buttons for each stage in block[0] and add them to the arrangedSubviews of the stackView
				
				// NOTE: I added one button to the allow access to the stage view controller screen (you will need to remove that from the storyboard when you do the real buttons here)
				
				
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
