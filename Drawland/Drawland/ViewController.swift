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
    lazy var path: UIBezierPath = {
        let path = UIBezierPath()
        
        path.lineWidth = 4.0
        
        return path
    }()
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: UITouch = touches.first!
        path.moveToPoint(touch.locationInView(self))
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: UITouch = touches.first!
        self.path.addLineToPoint(touch.locationInView(self))
        self.setNeedsDisplay()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: UITouch = touches.first!
        path.addLineToPoint(touch.locationInView(self))
        self.setNeedsDisplay()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        self.touchesEnded(touches!, withEvent: event)
    }
    
    override func drawRect(rect: CGRect) {
        path.stroke()
    }
    
    override func canBecomeFocused() -> Bool {
        return true
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        
        if context.nextFocusedView == self {
            
            coordinator.addCoordinatedAnimations({ () -> Void in
                
                self.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.2)
                
                }, completion: nil)
            
        } else if context.previouslyFocusedView == self {
            
            coordinator.addCoordinatedAnimations({ () -> Void in
                
                self.backgroundColor = UIColor.redColor()
                
                }, completion: nil)
            
        }
        
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

