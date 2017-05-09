//
//  MyPlanViewController.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 5/8/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import UIKit

class MyPlanViewController: UIViewController {
	
	@IBOutlet weak var stackView: UIStackView!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		title = NSLocalizedString("My Plan", comment: "my plan title")
		
		let buttonTitles = [NSLocalizedString("Colleges", comment: "Colleges title"), NSLocalizedString("Scholarships", comment: "Scholarships title"), NSLocalizedString("ACT / SAT", comment: "ACT / SAT title"), NSLocalizedString("Residency Info", comment: "Residency Info title")]
		
		
		for (index, title) in buttonTitles.enumerated() {
			
			let button = UIButton(type: .custom)
			button.tag = index
			button.setTitle(title, for: .normal)
			button.addTarget(self, action: #selector(self.handleTap(_:)), for: .touchUpInside)
			button.isEnabled = true
			
			button.titleLabel?.font = UIFont.systemFont(ofSize: 22.0)
			button.titleLabel?.numberOfLines = 0
			button.titleLabel?.textAlignment = .center
			button.setTitleColor(.white, for: .normal)
			button.setTitleColor(.lightGray, for: .highlighted)
			
			button.layer.cornerRadius = 5.0
			button.layer.backgroundColor = UIColor.magenta.withAlphaComponent(button.isEnabled ? 0.5 : 0.1).cgColor
			
			stackView.addArrangedSubview(button)
			
			button.widthAnchor.constraint(equalTo: self.stackView.widthAnchor, multiplier: 0.8).isActive = true
			button.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
		}
		
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
	
	dynamic func handleTap(_ button: UIButton) {
		
		switch button.tag {
		case 0:
			let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "colleges") as! MyPlanCollegesViewController
			self.navigationController?.pushViewController(vc, animated: true)
		default:
			break
		}
	}
	

}
