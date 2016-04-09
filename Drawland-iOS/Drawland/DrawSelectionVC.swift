//
//  DrawSelectionVC.swift
//  Drawland
//
//  Created by Matheo Fiebiger on 4/9/16.
//  Copyright © 2016 maluan. All rights reserved.
//

import UIKit

class DrawSelectionVC: UIViewController {

    @IBOutlet weak var drawWordDisplayLabel: UILabel!
    
    var options = ["CAT", "DOG", "HORSE", "MOUSE","PIG","LION","LLAMA","DOLPHIN","APE"]
    var currentWord = "CAT"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentWord = options[Int(arc4random_uniform(UInt32(options.count)))]
        
        self.drawWordDisplayLabel.text = currentWord
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dest = segue.destinationViewController as? DrawGuessingVC {
        dest.word = currentWord
        
        }
    }

}
