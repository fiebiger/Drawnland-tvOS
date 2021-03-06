//
//  ViewController.swift
//  Drawland
//
//  Created by Matheo Fiebiger on 4/9/16.
//  Copyright © 2016 maluan. All rights reserved.
//

import UIKit
import GameController
import Alamofire

class TouchTrackerView: UIView
{
    lazy var cursor: UIView = {
        let cursor = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        
        cursor.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        cursor.layer.cornerRadius = 15
        cursor.hidden = true
        
        self.addSubview(cursor)

        cursor.layer.masksToBounds = false
        cursor.layer.shadowColor = UIColor.blackColor().CGColor
        cursor.layer.shadowOffset = CGSize(width: 0, height: 0)
        cursor.layer.shadowRadius = 10
        cursor.layer.shadowOpacity = 0.3
        cursor.layer.shadowPath = UIBezierPath(rect: cursor.bounds).CGPath

        return cursor
    }()
    
    lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapAction(_:)))
        
        self.addGestureRecognizer(gesture)
        
        return gesture
    }()
    
    lazy var path: UIBezierPath = {
        let path = UIBezierPath()
        
        path.lineWidth = 8.0
        path.miterLimit = -20
        path.lineCapStyle = .Round
        path.lineJoinStyle = .Round
        
        return path
    }()
    
    var lastTouch: UITouch?
    var restartTouch : UITouch?
    
    var drawingMode = false
    
    func didTapAction(sender: UITapGestureRecognizer)
    {
        drawingMode = !drawingMode
        
        if let restartTouch = restartTouch where drawingMode {
            
            let location = restartTouch.locationInView(self)
            path.moveToPoint(location)
        }
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        _ = tapGesture
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 30
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).CGPath
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        guard let touch: UITouch = touches.first else { return }
        let location = touch.locationInView(self)
        
        if (drawingMode) {
            path.moveToPoint(location)
        } else {
            
            restartTouch = touch
        }
        
        // Cursor
        cursor.hidden = false
        cursor.center = location
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        guard let touch = touches.first else { return }
        
        let location = touch.locationInView(self)
        
        if (drawingMode) {
            self.path.addLineToPoint(location)
            self.setNeedsDisplay()
        }

        // Cursor
        cursor.center = location
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        guard let touch: UITouch = touches.first else { return }
        
        if (drawingMode) {
            path.addLineToPoint(touch.locationInView(self))
            self.setNeedsDisplay()
        }
        
        drawingMode = false

        // Cursor
        cursor.hidden = true
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?)
    {
        self.touchesEnded(touches!, withEvent: event)
    }
    
    override func drawRect(rect: CGRect)
    {
        UIColor.whiteColor().setStroke()
        
        path.stroke()
    }
    
    func clear()
    {
        path.removeAllPoints()
        self.setNeedsDisplay()
    }
    
    override func canBecomeFocused() -> Bool {
        return true
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        
        if context.nextFocusedView == self {
            
            coordinator.addCoordinatedAnimations({ () -> Void in
                
                self.layer.shadowOpacity = 0.4
                
            }, completion: nil)
            
        } else if context.previouslyFocusedView == self {
            
            coordinator.addCoordinatedAnimations({ () -> Void in
                
                self.layer.shadowOpacity = 0
                
                }, completion: nil)
            
        }
        
    }
}

class AnswersCell: UITableViewCell
{
    @IBOutlet weak var mainTitle: UILabel!
    
    override func canBecomeFocused() -> Bool {
        return false
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var overlayLabel: UILabel!
    @IBOutlet weak var touchView: TouchTrackerView!
    @IBOutlet weak var answersTableView: UITableView!
    @IBOutlet weak var overlayView: UIView!
    
    var statusTimer : NSTimer!
    var answersTimer : NSTimer!
    
    var currentGameId : String? {
        
        didSet {
            
            self.answersTimer = NSTimer(timeInterval: 1, target: self, selector: #selector(ViewController.answersTimerFired(_:)), userInfo: nil, repeats: false)
            
            NSRunLoop.mainRunLoop().addTimer(self.answersTimer, forMode: NSRunLoopCommonModes)
        }
    }
    
    var tries : [String] = ["No attempts yet"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        answersTableView.layer.cornerRadius = 10
        
        touchView.layer.cornerRadius = 10
        
        statusTimer = NSTimer(
            timeInterval: 0.2,
            target: self,
            selector: #selector(ViewController.statusTimerFired(_:)),
            userInfo: nil,
            repeats: true
        )
        
        NSRunLoop.mainRunLoop().addTimer(statusTimer, forMode: NSRunLoopCommonModes)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clearAction(sender: AnyObject)
    {
        touchView.clear()
    }
    
    func statusTimerFired(timer: NSTimer) {
        
        Alamofire.request(
            .GET,
            "https://drawland.firebaseio.com/.json")
        .validate()
        .responseJSON { (let response) in
            
            switch response.result {
                
            case .Success(let json):
                
                if let gameId = json["current_game"] as? String {
                    
                    if self.currentGameId != gameId {
                        
                        self.currentGameId = gameId
                    }
                }
                
            default:
                break
            }
        }
    }
    
    func answersTimerFired(timer: NSTimer) {
        
        Alamofire.request(.GET, "https://drawland.firebaseio.com/\(currentGameId!)/.json")
            .validate()
            .responseJSON { (let result) in
                
                switch result.result {
                    
                case let .Success(json):
                    
                    if let state = json["state"] as? String {
                        
                        if state == "Started" {

                            // Start the game
                            self.overlayView.hidden = true
                            
                            self.answersTimer = NSTimer(timeInterval: 1, target: self, selector: #selector(ViewController.answersTimerFired(_:)), userInfo: nil, repeats: false)
                            
                            NSRunLoop.mainRunLoop().addTimer(self.answersTimer, forMode: NSRunLoopCommonModes)

                        } else if state == "Won" {

                            self.overlayView.hidden = false

                            self.overlayLabel.text = "🎉 You won 🎉"
                            
                            self.touchView.clear()
                            
                            self.tries.removeAll()
                            
                        } else if state == "Lost" {
                            
                            self.overlayView.hidden = false
                            
                            self.overlayLabel.text = "You lost, try again 😉"
                            
                            self.touchView.clear()
                            
                            self.tries.removeAll()
                        
                        } else {
                            
                            self.overlayView.hidden = false
                        }
                    }
                    
                    if let attempts = json["try"] as? [String : AnyObject] {
                        
                        self.tries.removeAll()
                        
                        attempts.forEach { (let key, let value) in
                            
                            if let attemptDictionary = value as? [String : AnyObject] {
                                
                                let attempt = attemptDictionary["word"] as! String
                                
                                self.tries.append(attempt)
                                
                                self.answersTableView.reloadData()
                            }
                        }
                    }
                    break
                default:
                    break
                }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tries.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Attempts"
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let headerView = view as! UITableViewHeaderFooterView
        
        headerView.textLabel?.textColor = UIColor.whiteColor()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AnswersCell") as! AnswersCell
        
        cell.mainTitle.text = tries[indexPath.row]
        
        return cell
    }
}

