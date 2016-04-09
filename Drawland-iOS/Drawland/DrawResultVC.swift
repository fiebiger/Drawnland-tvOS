//
//  DrawResultVC.swift
//  Drawland
//
//  Created by Matheo Fiebiger on 4/9/16.
//  Copyright © 2016 maluan. All rights reserved.
//

import UIKit

class DrawResultVC: UIViewController {

    @IBOutlet weak var successLabel: UILabel!
    var success:Bool!
    
        override func viewDidLoad() {
        super.viewDidLoad()
        
            if(!success){
            successLabel.text = "TIME IS UP!"
            successLabel.textColor = .redColor()
            }
            
                // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

        
    
}
