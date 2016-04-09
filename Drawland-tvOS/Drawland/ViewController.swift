//
//  ViewController.swift
//  Drawland
//
//  Created by Matheo Fiebiger on 4/9/16.
//  Copyright © 2016 maluan. All rights reserved.
//

import UIKit
import GameController

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
        
        path.lineWidth = 6.0
        
        return path
    }()
    
    var lastTouch: UITouch?
    var restartTouch : UITouch?
    
    var drawingMode = false
    
    func didTapAction(sender: UITapGestureRecognizer)
    {
        drawingMode = true
        
        if let restartTouch = restartTouch {
            
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
    
//    private func _elaborateNewPoint(touch: UITouch) -> CGPoint {
//        
//        guard let lastTouch = lastTouch else { return touch.locationInView(self) }
//        
//        // calculate the delta
//        let delta = (lastTouch.locationInView(self).x - lastTouch.previousLocationInView(self).x, lastTouch.locationInView(self).y - lastTouch.previousLocationInView(self).y)
//        
//        let elaboratedDelta = ((delta.0 - 10 > 0) ? delta.0 - 10 : delta.0, delta.1 - 10)
//    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?)
    {
        self.touchesEnded(touches!, withEvent: event)
    }
    
    override func drawRect(rect: CGRect)
    {
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

    @IBOutlet weak var touchView: TouchTrackerView!
    @IBOutlet weak var answersTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        answersTableView.backgroundColor = UIColor.whiteColor()
        answersTableView.layer.cornerRadius = 10
        
        touchView.layer.cornerRadius = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clearAction(sender: AnyObject)
    {
        touchView.clear()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Answers"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AnswersCell") as! AnswersCell
        
        cell.mainTitle.text = "Test"
        
        return cell
    }
}

