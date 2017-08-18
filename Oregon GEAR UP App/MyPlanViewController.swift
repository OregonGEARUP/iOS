//
//  MyPlanViewController.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 5/8/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import UIKit

class MyPlanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet weak var tableView: UITableView!
	
	public var planIndexToShow = -1
	
	private let titles = ["Start with the checklist; the info and deadlines you need will be here.", NSLocalizedString("Colleges", comment: "Colleges title"), NSLocalizedString("Scholarships", comment: "Scholarships title"), NSLocalizedString("ACT / SAT", comment: "ACT / SAT title"), NSLocalizedString("Residency Info", comment: "Residency Info title"), NSLocalizedString("Calendar", comment: "Calendar title")]
	private let images = [#imageLiteral(resourceName: "Colleges"), #imageLiteral(resourceName: "Colleges"), #imageLiteral(resourceName: "Scholarships"), #imageLiteral(resourceName: "ACTSAT"), #imageLiteral(resourceName: "Residency"), #imageLiteral(resourceName: "Calendar")]
	
    override func viewDidLoad() {
        super.viewDidLoad()

		title = NSLocalizedString("My Plan", comment: "my plan title")
		
		tableView.rowHeight = 80
//		tableView.bounces = false
		tableView.delegate = self
		tableView.dataSource = self
		tableView.backgroundColor = .clear
		tableView.separatorStyle = .singleLine
		tableView.separatorColor = StyleGuide.myPlanColor
		
		StyleGuide.addGradientLayerTo(view)
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
	
	public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return indexPath.row > 0 ? 80 : 90
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "myplancell", for: indexPath)
		
		if indexPath.row == 0 {
			cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 17.0)
			cell.textLabel?.textColor = .gray
		} else {
			cell.textLabel?.font = UIFont.systemFont(ofSize: 24.0)
			cell.textLabel?.textColor = StyleGuide.myPlanColor
		}
		
		cell.selectionStyle = .none
		cell.textLabel?.numberOfLines = 0
		cell.backgroundColor = .clear
		cell.contentView.backgroundColor = .clear
		
		cell.textLabel?.text = titles[indexPath.row]
		cell.imageView?.image = indexPath.row > 0 ? images[indexPath.row] : nil
		return cell
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		showPlan(atIndex: indexPath.row)
	}

	private func showPlan(atIndex index: Int, animated: Bool = true) {
		switch index {
		case 1:
			let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "colleges") as! MyPlanCollegesViewController
			self.navigationController?.pushViewController(vc, animated: animated)
		case 2:
			let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "scholarships") as! MyPlanScholarshipsViewController
			self.navigationController?.pushViewController(vc, animated: animated)
		case 3:
			let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "testresults") as! MyPlanTestResultsViewController
			self.navigationController?.pushViewController(vc, animated: animated)
		case 4:
			let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "residency") as! MyPlanResidencyViewController
			self.navigationController?.pushViewController(vc, animated: animated)
		case 5:
			let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "calendar") as! MyPlanCalendarViewController
			self.navigationController?.pushViewController(vc, animated: animated)
		default:
			break
		}
	}
}
