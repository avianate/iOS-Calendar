//
//  PopAnimator.swift
//  Calendar
//
//  Created by Nate Graham on 9/19/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import Foundation
import UIKit

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 1.0
    var originFrame = CGRect.zero
    var presenting = true
    var selectedIndexPath: IndexPath?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // 1. set up transition
        
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let monthView = presenting ? toView : transitionContext.view(forKey: .from)!
        
        let initialFrame = presenting ? originFrame : monthView.frame
        let finalFrame = presenting ? monthView.frame : originFrame
        
        let initialXScale = presenting ? initialFrame.width / finalFrame.width : finalFrame.width / initialFrame.width
        let initialYScale = presenting ? initialFrame.height / finalFrame.height : finalFrame.height / initialFrame.height
        let scaleFactor = CGAffineTransform(scaleX: initialXScale, y: initialYScale)
        
        if presenting {
            // initial scale
            monthView.transform = scaleFactor
            monthView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
        }
        
        containerView.addSubview(toView)
        containerView.bringSubviewToFront(monthView)
        
        let monthController = transitionContext.viewController(forKey: presenting ? .to : .from) as! MonthViewController
        
        if presenting {
            monthController.calendarView.alpha = 0.0
        }
        
        // 2. Animate
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0, animations: {
            monthView.transform = self.presenting ? .identity : scaleFactor // final scale
            monthView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
            monthController.calendarView.alpha = self.presenting ? 1.0 : 0.0
        }, completion: { success in
            
            // 3. Complete transition
            if !self.presenting {
//                do anything you need to do to the year view controller here
//                let yearViewController = transitionContext.viewController(forKey: .to) as! YearViewController
            }
            
            // remember to call this method or the transition will never complete and the user won't be able to interact
            transitionContext.completeTransition(success)
        })
    }
}
