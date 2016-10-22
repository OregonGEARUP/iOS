//
//  ViewController.swift
//  OR GEAR UP iOS JSON Parsing
//
//  Created by Max MacEachern on 9/26/16.
//  Copyright © 2016 Max MacEachern. All rights reserved.
//

import UIKit



class WebViewController: UIViewController {
    var url: String!
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = URLRequest(url: URL(string:self.url)!)
        self.webView.loadRequest(request)
    }
}


class ViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var moreInfoButton: UIButton!
    @IBOutlet weak var PrevButton: UIButton!
    @IBOutlet weak var NextButton: UIButton!
    @IBOutlet weak var fieldLabel1: UILabel!
    @IBOutlet weak var inputField1: UITextField!
    @IBOutlet weak var fieldLabel2: UILabel!
    @IBOutlet weak var inputField2: UITextField!
    @IBOutlet weak var fieldLabel3: UILabel!
    @IBOutlet weak var inputField3: UITextField!
    @IBOutlet var radioButtons: [UIButton]!
    @IBOutlet weak var groupStackview: UIStackView!
    @IBOutlet weak var fieldStackview: UIStackView!
    @IBOutlet weak var checkboxStackview: UIStackView!
    @IBOutlet weak var radioStackview: UIStackView!
    @IBOutlet var checkboxesButtons: [UIButton]!

    var cpIndex: Int = 0
    
    func loadCP(index: Int){
        let cp = CheckpointManager.sharedManager.checkpoints[index]
        
        self.titleLabel.text = cp.title
        self.descriptionLabel.text = cp.description
        
        if let moreInfo = cp.moreInfo {
            self.moreInfoButton.setTitle(moreInfo, for: .normal)
            self.moreInfoButton.isHidden = false
        } else {
            self.moreInfoButton.isHidden = true
        }
        
        let type = cp.entry.type
        switch type {
        case .FieldEntry:
            showStack(stack: fieldStackview)
            hideStack(stack: checkboxStackview)
            hideStack(stack: radioStackview)
            self.fieldLabel1.text = cp.entry.instances[0].prompt
            self.fieldLabel2.text = cp.entry.instances[1].prompt
            self.fieldLabel3.text = cp.entry.instances[2].prompt
        
        case .CheckboxEntry:
            showStack(stack: checkboxStackview)
            hideStack(stack: fieldStackview)
            hideStack(stack: radioStackview)
            var checkboxIndex: Int = 0
            for checkbox in checkboxesButtons {
                checkbox.setTitle(cp.entry.instances[checkboxIndex].prompt, for: .normal)
                checkbox.setTitle(cp.entry.instances[checkboxIndex].prompt, for: .selected)
                checkboxIndex += 1
            }
            
        case .RadioEntry:
            showStack(stack: radioStackview)
            hideStack(stack: fieldStackview)
            hideStack(stack: checkboxStackview)
            var radiobuttonIndex: Int = 0
            for radio in radioButtons {
                radio.setTitle(cp.entry.instances[radiobuttonIndex].prompt, for: .normal)
                radio.setTitle(cp.entry.instances[radiobuttonIndex].prompt, for: .selected)
                radiobuttonIndex += 1
            }
        
        case .FieldDateEntry:
            hideStack(stack: fieldStackview)
            hideStack(stack: checkboxStackview)
            hideStack(stack: radioStackview)
        }
        
        
    }
    func nextCP(){
        let maxCP = CheckpointManager.sharedManager.checkpoints.count
        if cpIndex < maxCP-1 {
            cpIndex = cpIndex + 1
            loadCP(index: cpIndex)
        }
    }
    
    func prevCP(){
        if cpIndex > 0 {
            cpIndex = cpIndex - 1
            loadCP(index: cpIndex)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Checkpoint"
        
        self.moreInfoButton.addTarget(self, action: #selector(showMoreInfo), for: .touchUpInside)
        
        self.NextButton.addTarget(self, action: #selector(nextCP), for: .touchUpInside)
        
        self.PrevButton.addTarget(self, action: #selector(prevCP), for: .touchUpInside)
        
        
        CheckpointManager.sharedManager.fetchJSON() { (success) in
            
            print("fetchJSON was successful: \(success)")
            
            
            self.loadCP(index: self.cpIndex)
            
       }
        
        
    }
    @IBAction func handleRadio(_ sender: UIButton) {
        
        for radio in radioButtons {
            radio.isSelected = false
        }
        
        sender.isSelected = true

    }
    @IBAction func handleCheckbox(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideStack(stack: UIStackView){
        stack.isHidden = true
    }
    
    func showStack(stack: UIStackView){
        stack.isHidden = false
    }
    
    // TODO: Make a generalized Stackview show/hide function
    /*func stackviewLoop(stack: UIStackView, groupStack: UIStackView){
        for stackview in groupStack {
            if stackview == stack {
                showStack(stackview)
            }
            else {
                hideStack(stack: stackview)
            }
        }
    }*/
    func showMoreInfo() {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "webview") as! WebViewController
        vc.url = CheckpointManager.sharedManager.checkpoints[cpIndex].moreInfo!
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
