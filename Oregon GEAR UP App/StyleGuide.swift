//
//  StyleGuide.swift
//  Oregon GEAR UP App
//
//  Created by Steve Splonskowski on 7/15/17.
//  Copyright © 2017 Oregon GEAR UP. All rights reserved.
//

import UIKit


struct StyleGuide {
	
	// gradient colors
	static let topGradientColor = UIColor.white
	static let bottomGradientColor = UIColor(red: 0x9b/255.0, green: 0xdf/255.0, blue: 0xf8/255.0, alpha: 1.0)
	
	static func addGradientLayerTo(_ view: UIView) {
		
		let maxDim = max(view.bounds.width, view.bounds.height)
		
		let gradient = CAGradientLayer()
		gradient.frame = CGRect(origin: view.bounds.origin, size: CGSize(width: maxDim, height: maxDim))
		gradient.colors = [topGradientColor.cgColor, bottomGradientColor.cgColor]
		gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
		gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
		
		view.layer.insertSublayer(gradient, at: 0)
	}
	
	static func addCongratsGradientLayerTo(_ view: UIView) {
		
		let gradient = CAGradientLayer()
		gradient.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 100.0)
		gradient.colors = [UIColor(red: 0.036, green: 0.152, blue: 0.211, alpha: 1.0).cgColor, UIColor(red: 0.498, green: 0.773, blue: 0.894, alpha: 1.0).cgColor]
		gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
		gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
		
		view.layer.insertSublayer(gradient, at: 0)
	}
	
	// button colors
	static let completeButtonColor = UIColor(red: 0x8c/255.0, green: 0xc6/255.0, blue: 0x3f/255.0, alpha: 1.0)
	static let inprogressButtonColor = UIColor(red: 0x00/255.0, green: 0xae/255.0, blue: 0xef/255.0, alpha: 1.0)
	static let inactiveButtonColor = UIColor(red: 0xd3/255.0, green: 0xe4/255.0, blue: 0xeb/255.0, alpha: 1.0)
	
	static let endOfSectionColor = UIColor(red: 0x00/255.0, green: 0xae/255.0, blue: 0xef/255.0, alpha: 1.0)
	
	static let myPlanColor = UIColor(red: 13.0/255, green: 162.0/255, blue: 218.0/255, alpha: 1.0)
}
