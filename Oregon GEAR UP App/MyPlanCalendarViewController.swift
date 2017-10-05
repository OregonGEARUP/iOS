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


class MyPlanCalendarViewController: UIViewController, JBDatePickerViewDelegate, UITableViewDataSource {
	
	var monthLabel: FadeTransitionLabel!
	var calendarView: JBDatePickerView!
	var eventsTableView: UITableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Calendar"
		
		monthLabel = FadeTransitionLabel()
		monthLabel.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(monthLabel)
		
		monthLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		monthLabel.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 16.0).isActive = true
		
		calendarView = JBDatePickerView()
		calendarView.delegate = self
		view.addSubview(calendarView)
		
		calendarView.translatesAutoresizingMaskIntoConstraints = false
		calendarView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 10.0).isActive = true
		calendarView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
		calendarView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
		calendarView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4).isActive = true
		
		let divider = UIView()
		view.addSubview(divider)
		
		divider.translatesAutoresizingMaskIntoConstraints = false
		divider.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 8.0).isActive = true
		divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
		divider.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		divider.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		
		eventsTableView = UITableView()
		eventsTableView.backgroundColor = .clear
		eventsTableView.rowHeight = UITableViewAutomaticDimension
		eventsTableView.estimatedRowHeight = 30.0
		eventsTableView.separatorInset = UIEdgeInsets.zero
		eventsTableView.dataSource = self
		eventsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "eventcell")
		view.addSubview(eventsTableView)
		
		eventsTableView.translatesAutoresizingMaskIntoConstraints = false
		eventsTableView.topAnchor.constraint(equalTo: divider.bottomAnchor).isActive = true
		eventsTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		eventsTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		eventsTableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
		
		divider.backgroundColor = eventsTableView.separatorColor

		
		let tgr = UITapGestureRecognizer(target: self, action: #selector(showCurrentMonth))
		monthLabel.addGestureRecognizer(tgr)
		monthLabel.isUserInteractionEnabled = true
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		MyPlanManager.shared.setupCalendarEvents()
		calendarView.updateEventIndicators()
		eventsTableView.reloadData()
	}
	
	
	// MARK: - calendar delegate
	
	func showCurrentMonth() {
		
		calendarView.contentController.setupMonthForDate(Date())
		
		calendarView.selectFirstDay()	// TODO: should select today!
		eventsTableView?.reloadData()
	}
	
	func didSelectDay(_ dayView: JBDatePickerDayView) {
		
		eventsTableView.reloadData()
		
//		guard let date = dayView.date else {
//			return
//		}
//		
//		if let events = MyPlanManager.shared.calendarEventsForDate(date) {
//			print(events)
//		}
	}
	
	func didPresentOtherMonth(_ monthView: JBDatePickerMonthView) {
		
		monthLabel.text = monthView.monthDescription
		
		calendarView.selectFirstDay()
		eventsTableView?.reloadData()
	}
	
	func hasEventsForDay(_ date: Date?) -> Bool {
		guard let date = date else {
			return false
		}
		
		return MyPlanManager.shared.hasCalendarEventsForDate(date)
	}
	
	var shouldShowMonthOutDates: Bool {
		return false
	}
	
	var colorForWeekDaysViewBackground: UIColor {
		return  StyleGuide.myPlanColor
	}

	var weekDaysViewHeightRatio: CGFloat {
		return 0.15
	}
	
	var selectionShape: JBSelectionShape {
		return .circle
	}
	
	
	// MARK: - event table data source
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		guard let date = calendarView.selectedDateView.date else {
			return 0
		}
		
		if let events = MyPlanManager.shared.calendarEventsForDate(date) {
			return events.count
		}
		
		return 1
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = UITableViewCell(style: .default, reuseIdentifier: "eventcell")
		cell.backgroundColor = .clear
		cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightLight)
		cell.textLabel?.textColor = .darkText
		cell.textLabel?.numberOfLines = 0
		cell.selectionStyle = .none
		
		if let date = calendarView.selectedDateView.date,
		   let events = MyPlanManager.shared.calendarEventsForDate(date)
		{
			cell.textLabel?.text = events[indexPath.row].description
		} else {
			cell.textLabel?.textColor = .gray
			cell.textLabel?.text = "no events"
		}
		
		return cell
	}
}
