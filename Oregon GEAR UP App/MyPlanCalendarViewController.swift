//
//  MyPlanCalendarViewController.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 6/21/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import UIKit

class MyPlanCalendarViewController: UIViewController, JBDatePickerViewDelegate {
	
	@IBOutlet weak var titleLabel: UILabel!
	var calendarView: JBDatePickerView!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Calendar"
		
		calendarView = JBDatePickerView()
		calendarView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(calendarView)
		
		calendarView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10.0).isActive = true
		calendarView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
		calendarView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
		calendarView.heightAnchor.constraint(equalToConstant: 260.0).isActive = true
		
		calendarView.delegate = self
    }
	
	func didSelectDay(_ dayView: JBDatePickerDayView) {
		print(dayView.date!)
	}
	
	func didPresentOtherMonth(_ monthView: JBDatePickerMonthView) {
		titleLabel.text = monthView.monthDescription
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
