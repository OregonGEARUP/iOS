//
//  MyPlanCalendarViewController.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 6/21/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import UIKit


class FadeTransitionLabel: UILabel {
	
	override func action(for layer: CALayer, forKey event: String) -> CAAction? {
		if event == "contents" {
			return CATransition()	// defaults to fade type
		}
		return super.action(for: layer, forKey: event)
	}
}


class MyPlanCalendarViewController: UIViewController, JBDatePickerViewDelegate {
	
	var monthLabel: FadeTransitionLabel!
	var calendarView: JBDatePickerView!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Calendar"
		
		monthLabel = FadeTransitionLabel()
		monthLabel.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(monthLabel)
		
		monthLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		monthLabel.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 16.0).isActive = true
		
		calendarView = JBDatePickerView()
		calendarView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(calendarView)
		
		calendarView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 10.0).isActive = true
		calendarView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
		calendarView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
		calendarView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4).isActive = true
		
		calendarView.delegate = self
		
		let tgr = UITapGestureRecognizer(target: self, action: #selector(showCurrentMonth))
		monthLabel.addGestureRecognizer(tgr)
		monthLabel.isUserInteractionEnabled = true
    }
	
	func showCurrentMonth() {
		
		calendarView.contentController.setupMonthForDate(Date())
	}
	
	func didSelectDay(_ dayView: JBDatePickerDayView) {
		print(dayView.date!)
	}
	
	func didPresentOtherMonth(_ monthView: JBDatePickerMonthView) {
		monthLabel.text = monthView.monthDescription
	}
	
	func hasEventsForDay(_ date: Date?) -> Bool {
		guard let date = date else {
			return false
		}
		
		// TEMPORARY for testing
		let comps = Calendar.current.dateComponents(Set([.month, .day]), from: date)
		return (comps.month == 7 && comps.day == 11) || (comps.month == 12 && comps.day == 22)
	}
	
	var colorForWeekDaysViewBackground: UIColor {
		return  UIColor(red: 0x8c/255.0, green: 0xc6/255, blue: 0x3f/255.0, alpha: 0.5)
	}

	var weekDaysViewHeightRatio: CGFloat {
		return 0.15
	}
	
	var selectionShape: JBSelectionShape {
		return .circle
	}

}
