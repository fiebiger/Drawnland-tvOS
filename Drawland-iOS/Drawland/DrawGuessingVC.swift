//
//  DrawGuessing.swift
//  Drawland
//
//  Created by Matheo Fiebiger on 4/9/16.
//  Copyright © 2016 maluan. All rights reserved.
//

import UIKit
import Firebase


class DrawGuessingVC: UIViewController,OEEventsObserverDelegate , UITableViewDelegate, UITableViewDataSource{

    
    lazy var firebaseRoot:Firebase = {
     return Firebase(url: "https://drawland.firebaseio.com")
    }()
    lazy var firebaseGameReference:Firebase = {
        return Firebase(url: "https://drawland.firebaseio.com/current_game")
    }()
    
    lazy var firebaseGame:Firebase = {
        return Firebase(url: "https://drawland.firebaseio.com/\(self.gameID!)/try")
    }()
    lazy var firebaseGameStatus:Firebase = {
        return Firebase(url: "https://drawland.firebaseio.com/\(self.gameID!)/state")
    }()

    
    
    var gameID:String?
    
    @IBOutlet weak var tableView: UITableView!
    var word:String!
    var attemps:[String] = []
    var timer:NSTimer?
    var count = 60 * 3
    
    @IBOutlet weak var timerLabel: UILabel!
    
    let openEarsEventsObserver = OEEventsObserver()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let game = ["state": "Started"]
       
        let newGame = firebaseRoot.childByAutoId()
        newGame.setValue(game)
        gameID = newGame.key
        
        firebaseGameReference.setValue(gameID)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view.
        
        openEarsEventsObserver.delegate = self
        
        
        let languageGenerator:OELanguageModelGenerator = OELanguageModelGenerator()
        let error = languageGenerator.generateLanguageModelFromTextFile(NSBundle.mainBundle().pathForResource("animals", ofType: "txt"), withFilesNamed: "EnglishModel", forAcousticModelAtPath:OEAcousticModel.pathToModel("AcousticModelEnglish"))
        
        if(error == nil){
            
            let lmPath = languageGenerator.pathToSuccessfullyGeneratedLanguageModelWithRequestedName("EnglishModel")
            let dicPath = languageGenerator.pathToSuccessfullyGeneratedDictionaryWithRequestedName("EnglishModel")
            
            do {
                try OEPocketsphinxController.sharedInstance().setActive(true)
                OEPocketsphinxController.sharedInstance().secondsOfSilenceToDetect = 0.2
                
                OEPocketsphinxController.sharedInstance().startListeningWithLanguageModelAtPath(lmPath, dictionaryAtPath: dicPath, acousticModelAtPath: OEAcousticModel.pathToModel("AcousticModelEnglish"), languageModelIsJSGF: false)
            } catch {
                
                
            }
            
        }else {
            
            print("language error")
            
        }
        

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attemps.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        if cell == nil {
        cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
        }
        
        cell?.textLabel?.text = attemps[indexPath.row].uppercaseString;
        return cell!
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     
        if let dest = segue.destinationViewController as? DrawResultVC {
            dest.success  = sender as! Bool
        }
        
    }
    
    // MARK: - Speach delegate
    
    func pocketsphinxDidReceiveHypothesis(hypothesis: String!, recognitionScore: String!, utteranceID: String!) {
        
        var array:[String] = hypothesis.componentsSeparatedByString(" ")
        
        for word in array {
        
            firebaseGame.childByAutoId().setValue(["word":word.uppercaseString])
        
        }
        
        array.appendContentsOf(attemps)
        attemps = array
        tableView.reloadData()
        if hypothesis.lowercaseString.rangeOfString(word.lowercaseString) != nil{
        OEPocketsphinxController.sharedInstance().stopListening()
            
            firebaseGameStatus.setValue("Won")
        self.performSegueWithIdentifier("finish", sender: true)
        }
    }
    
    func pocketsphinxDidStartListening() {
        print("started listening")
    }
    
    func pocketsphinxDidDetectSpeech() {
        print("started detected speach")
        
    }
    
    func pocketsphinxDidDetectFinishedSpeech() {
        print("finished detecting speach")
        
    }
    
    func pocketSphinxContinuousTeardownDidFailWithReason(reasonForFailure: String!) {
        print(reasonForFailure)
    }
    
    func pocketSphinxContinuousSetupDidFailWithReason(reasonForFailure: String!) {
        print("Listening setup wasn't successful and returned the failure reason: \(reasonForFailure)")
        
    }
    
    func updateTimer(){
        if(count > 0){
            let minutes = String(count / 60)
            let seconds = String(count % 60)
            timerLabel.text = minutes + ":" + (seconds.characters.count == 1 ? seconds + "0" : seconds) + " REMAINING"
            count -= 1
        }else{
        timer?.invalidate()
            
        firebaseGameStatus.setValue("Lost")
        self.performSegueWithIdentifier("finish", sender: false)
        }
    }


}
