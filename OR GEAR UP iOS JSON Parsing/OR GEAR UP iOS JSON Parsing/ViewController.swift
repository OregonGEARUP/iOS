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
        
        self.fieldLabel1.text = cp.entry.instances[0].prompt
        self.fieldLabel2.text = cp.entry.instances[1].prompt
        self.fieldLabel3.text = cp.entry.instances[2].prompt
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
        
        
        loadCP(index: cpIndex)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showMoreInfo() {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "webview") as! WebViewController
        vc.url = CheckpointManager.sharedManager.checkpoints[cpIndex].moreInfo!
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
