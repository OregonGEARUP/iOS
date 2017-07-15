//
//  MyPlanViewController.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 5/8/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import UIKit

class MyPlanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet weak var stackView: UIStackView!
	@IBOutlet weak var tableView: UITableView!
	
	public var planIndexToShow = -1
	
	private let titles = [NSLocalizedString("Colleges", comment: "Colleges title"), NSLocalizedString("Scholarships", comment: "Scholarships title"), NSLocalizedString("ACT / SAT", comment: "ACT / SAT title"), NSLocalizedString("Residency Info", comment: "Residency Info title"), NSLocalizedString("Calendar", comment: "Calendar title")]
	private let images = [#imageLiteral(resourceName: "Colleges"), #imageLiteral(resourceName: "Scholarships"), #imageLiteral(resourceName: "ACTSAT"), #imageLiteral(resourceName: "Residency"), #imageLiteral(resourceName: "Calendar")]
	
    override func viewDidLoad() {
        super.viewDidLoad()

		title = NSLocalizedString("My Plan", comment: "my plan title")
		
		tableView.rowHeight = 80
		tableView.delegate = self
		tableView.dataSource = self
		
		StyleGuide.addGradientLayerTo(view)
		
		tableView.backgroundColor = .clear
		
//		for (index, title) in titles.enumerated() {
//			
//			let button = UIButton(type: .custom)
//			button.tag = index
//			button.setTitle(title, for: .normal)
//			button.addTarget(self, action: #selector(self.handleTap(_:)), for: .touchUpInside)
//			button.isEnabled = true
//			
//			button.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
//			button.titleLabel?.numberOfLines = 0
//			button.titleLabel?.textAlignment = .center
//			button.setTitleColor(.white, for: .normal)
//			button.setTitleColor(.lightGray, for: .highlighted)
//			
//			button.layer.cornerRadius = 5.0
//			button.layer.backgroundColor = StyleGuide.completeButtonColor.cgColor
//			
//			stackView.addArrangedSubview(button)
//			
//			button.widthAnchor.constraint(equalTo: self.stackView.widthAnchor, multiplier: 0.8).isActive = true
//			button.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
//		}
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if planIndexToShow >= 0 {
			showPlan(atIndex: planIndexToShow, animated: false)
			planIndexToShow = -1
		}
	}
	
	dynamic func handleTap(_ button: UIButton) {
		showPlan(atIndex: button.tag)
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return titles.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "myplancell", for: indexPath)
		cell.textLabel?.font = UIFont.systemFont(ofSize: 24.0)
		cell.textLabel?.textColor = StyleGuide.myPlanColor
		cell.backgroundColor = .clear
		cell.contentView.backgroundColor = .clear
		
		cell.textLabel?.text = titles[indexPath.row]
		cell.imageView?.image = images[indexPath.row]
		return cell
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		showPlan(atIndex: indexPath.row)
	}

	
	private func showPlan(atIndex index: Int, animated: Bool = true) {
		switch index {
		case 0:
			let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "colleges") as! MyPlanCollegesViewController
			self.navigationController?.pushViewController(vc, animated: animated)
		case 1:
			let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "scholarships") as! MyPlanScholarshipsViewController
			self.navigationController?.pushViewController(vc, animated: animated)
		case 2:
			let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "testresults") as! MyPlanTestResultsViewController
			self.navigationController?.pushViewController(vc, animated: animated)
		case 3:
			let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "residency") as! MyPlanResidencyViewController
			self.navigationController?.pushViewController(vc, animated: animated)
		case 4:
			let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "calendar") as! MyPlanCalendarViewController
			self.navigationController?.pushViewController(vc, animated: animated)
		default:
			break
		}
	}
}
