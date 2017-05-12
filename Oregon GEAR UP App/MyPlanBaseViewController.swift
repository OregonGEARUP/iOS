//
//  MyPlanBaseViewController.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 5/11/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import UIKit

class MyPlanBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

		createDatePickerPaletteView()
		createKeyboardAccessoryView()
    }
	
	
	// MARK: date picker support
	
	private let datePickerPaletteHeight: CGFloat = 200.0
	private var datePickerPaletteView: UIView!
	private var datePicker: UIDatePicker!
	private var datePickerTopConstraint: NSLayoutConstraint!
	private var currentInputDate: UIButton?
	
	private func createDatePickerPaletteView() {
		
		datePickerPaletteView = UIView()
		datePickerPaletteView.translatesAutoresizingMaskIntoConstraints = false
		datePickerPaletteView.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 1.0, alpha: 1.0)
		view.addSubview(datePickerPaletteView)
		datePickerTopConstraint = datePickerPaletteView.topAnchor.constraint(equalTo: view.bottomAnchor)
		NSLayoutConstraint.activate([
			datePickerPaletteView.widthAnchor.constraint(equalTo: view.widthAnchor),
			datePickerPaletteView.heightAnchor.constraint(equalToConstant: datePickerPaletteHeight),
			datePickerPaletteView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			datePickerTopConstraint
			])
		
		let topLine = UIView()
		topLine.translatesAutoresizingMaskIntoConstraints = false
		topLine.backgroundColor = .gray
		datePickerPaletteView.addSubview(topLine)
		NSLayoutConstraint.activate([
			topLine.topAnchor.constraint(equalTo: datePickerPaletteView.topAnchor),
			topLine.widthAnchor.constraint(equalTo: datePickerPaletteView.widthAnchor),
			topLine.heightAnchor.constraint(equalToConstant: 0.5)
			])
		
		datePicker = UIDatePicker()
		datePicker.translatesAutoresizingMaskIntoConstraints = false
		datePicker.addTarget(self, action: #selector(datePickerChanged(_:)), for: UIControlEvents.valueChanged)
		datePicker.datePickerMode = .date
		datePickerPaletteView.addSubview(datePicker)
		NSLayoutConstraint.activate([
			datePicker.topAnchor.constraint(equalTo: datePickerPaletteView.topAnchor, constant: 16.0),
			datePicker.centerXAnchor.constraint(equalTo: datePickerPaletteView.centerXAnchor)
			])
		
		let doneBtn = UIButton(type: .system)
		doneBtn.translatesAutoresizingMaskIntoConstraints = false
		doneBtn.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
		doneBtn.addTarget(self, action: #selector(doneWithDatePicker), for: .touchUpInside)
		datePickerPaletteView.addSubview(doneBtn)
		NSLayoutConstraint.activate([
			doneBtn.topAnchor.constraint(equalTo: datePickerPaletteView.topAnchor, constant: 2.0),
			doneBtn.rightAnchor.constraint(equalTo: datePickerPaletteView.rightAnchor, constant: -20.0)
			])
	}
	
	public dynamic func toggleDatePicker(_ button: UIButton) {
		
		// hide keyboard first
		doneWithKeyboard(btn: nil)
		
		// track whether picker will become visible
		let datePickerVisible = (datePickerTopConstraint.constant == 0)
		
		if datePickerVisible {
			
			let dateFormatter = DateFormatter()
			dateFormatter.dateStyle = .long
			dateFormatter.timeStyle = .none
			
			if let dateStr = button.title(for: .normal),
				let date = dateFormatter.date(from: dateStr) {
				
				datePicker.date = date
			}
		}
		
		view.layoutIfNeeded()
		UIView.animate(withDuration: 0.3, animations: {
			self.datePickerTopConstraint.constant = (self.datePickerTopConstraint.constant == 0 ? -(self.datePickerPaletteHeight + 50.0) : 0.0)
			self.view.layoutIfNeeded()
		})
		
		// keep track of which button triggered the date picker
		currentInputDate = (datePickerVisible ? button : nil)
	}
	
	public dynamic func doneWithDatePicker() {
		
		view.layoutIfNeeded()
		UIView.animate(withDuration: 0.3, animations: {
			self.datePickerTopConstraint.constant = 0.0
			self.view.layoutIfNeeded()
		})
		
		currentInputDate = nil
	}
	
	private dynamic func datePickerChanged(_ datePicker: UIDatePicker) {
		
		if let button = currentInputDate {
			dateChanged(datePicker.date, forButton: button)
		}
	}
	
	public func dateChanged(_ date: Date, forButton button: UIButton) {
		
		// override point
	}
	
	
	// MARK: - text field keyboard handling
	
	public var keyboardAccessoryView: UIView!
	
	private func createKeyboardAccessoryView() {
		
		// add a done button for the keyboard
		keyboardAccessoryView = UIView(frame: CGRect(x:0.0, y:0.0, width:0.0, height:40.0))
		keyboardAccessoryView.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 1.0, alpha: 1.0)
		
		let topLine = UIView()
		topLine.translatesAutoresizingMaskIntoConstraints = false
		topLine.backgroundColor = .gray
		keyboardAccessoryView.addSubview(topLine)
		
		//		let prevBtn = UIButton(type: .system)
		//		prevBtn.translatesAutoresizingMaskIntoConstraints = false
		//		prevBtn.setTitle("<", for: .normal)
		//		prevBtn.addTarget(self, action: #selector(previousField(btn:)), for: .touchUpInside)
		//		keyboardAccessoryView.addSubview(prevBtn)
		//
		//		let nextBtn = UIButton(type: .system)
		//		nextBtn.translatesAutoresizingMaskIntoConstraints = false
		//		nextBtn.setTitle(">", for: .normal)
		//		nextBtn.addTarget(self, action: #selector(nextField(btn:)), for: .touchUpInside)
		//		keyboardAccessoryView.addSubview(nextBtn)
		
		let doneBtn = UIButton(type: .system)
		doneBtn.translatesAutoresizingMaskIntoConstraints = false
		doneBtn.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
		doneBtn.addTarget(self, action: #selector(doneWithKeyboard(btn:)), for: .touchUpInside)
		keyboardAccessoryView.addSubview(doneBtn)
		
		NSLayoutConstraint.activate([
			topLine.topAnchor.constraint(equalTo: keyboardAccessoryView.topAnchor),
			topLine.widthAnchor.constraint(equalTo: keyboardAccessoryView.widthAnchor),
			topLine.heightAnchor.constraint(equalToConstant: 0.5),
			//			prevBtn.topAnchor.constraint(equalTo: keyboardAccessoryView.topAnchor),
			//			prevBtn.bottomAnchor.constraint(equalTo: keyboardAccessoryView.bottomAnchor),
			//			prevBtn.leadingAnchor.constraint(equalTo: keyboardAccessoryView.leadingAnchor, constant: 20.0),
			//			nextBtn.topAnchor.constraint(equalTo: keyboardAccessoryView.topAnchor),
			//			nextBtn.bottomAnchor.constraint(equalTo: keyboardAccessoryView.bottomAnchor),
			//			nextBtn.leadingAnchor.constraint(equalTo: prevBtn.trailingAnchor, constant: 20.0),
			doneBtn.topAnchor.constraint(equalTo: keyboardAccessoryView.topAnchor),
			doneBtn.bottomAnchor.constraint(equalTo: keyboardAccessoryView.bottomAnchor),
			doneBtn.trailingAnchor.constraint(equalTo: keyboardAccessoryView.trailingAnchor, constant: -20.0)
			])
	}
	
	public dynamic func doneWithKeyboard(btn: UIButton?) {
		
		view.endEditing(true)
	}

}