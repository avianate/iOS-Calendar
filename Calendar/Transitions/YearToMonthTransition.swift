//
//  YearToMonthTransition.swift
//  Calendar
//
//  Created by Nate Graham on 9/25/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import UIKit

class YearToMonthTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var presenting = false
    var originalBackgroundColor: UIColor!
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? YearViewController,
            let toVC = transitionContext.viewController(forKey: .to) as? MonthViewController,
            let snapshot = fromVC.view.snapshotView(afterScreenUpdates: false) else {
                // don't transition, just stay on the original view controller
                transitionContext.completeTransition(false)
                return
        }
        
        // save this to an instance variable to be used by the mask layer animation
        let context = transitionContext
        
        let containerView = transitionContext.containerView
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // get selected month cell
        if let window = appDelegate.window, let selectedMonth = fromVC.selectedMonth {
            
            let frame = CGRect(x: 0.0, y: 0.0, width: window.frame.width, height: window.frame.height)
            let backgroundView = UIView(frame: frame)
            backgroundView.backgroundColor = .white
            containerView.addSubview(backgroundView)
            
            containerView.addSubview(snapshot)
            fromVC.removeFromParent()
    
            let originFrame = selectedMonth.superview?.convert(selectedMonth.frame, to: nil)
            let finalFrame = toVC.calendarView.frame
            
            // get scale factor
            let xScaleFactor = window.frame.width / originFrame!.width
            let yScaleFactor =  finalFrame.height / originFrame!.height

            let initialXScale = originFrame!.width / window.frame.width
            let initialYScale = originFrame!.height / window.frame.height

            // get new origin
            let newPoint = getOffsetBetween(originFrame: originFrame!, window: fromVC.calendarView.frame, andFinalFrame: finalFrame, withXScaleX: xScaleFactor, andScaleY: yScaleFactor)
            
            toVC.view.alpha = 0.0
            originalBackgroundColor = toVC.view.backgroundColor
            toVC.view.backgroundColor = .white
            toVC.calendarView.backgroundColor = .white
            toVC.tableView.transform = CGAffineTransform(translationX: 0.0, y: window.frame.height)
            toVC.view.transform = CGAffineTransform(scaleX: initialXScale, y: initialYScale)
            toVC.view.center = CGPoint(x: originFrame!.midX, y: originFrame!.midY + 25)
            toVC.calendarHeightConstraint.constant = originFrame!.height
            
            containerView.addSubview(toVC.view)
            containerView.bringSubviewToFront(toVC.view)
            
            UIView.animate(withDuration: 0.5, animations: {
                // set scale and origin to zoom into month cell
                snapshot.transform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
                snapshot.center = newPoint
                snapshot.alpha = 0.0
//                fromVC.calendarView.backgroundColor = toVC.calendarView.backgroundColor
                // fade out yearVC
//                fromVC.view.alpha = 0.0
                
                // fade in monthViewController
                toVC.view.alpha = 1.0
                // change backgroundColor back to original
                toVC.tableView.transform = .identity
                toVC.calendarHeightConstraint.constant = 240
                // zoom in and center
                toVC.view.transform = .identity
                toVC.view.center = CGPoint(x: window.frame.midX, y: window.frame.midY)
                
            }, completion: { success in
                // clean up
                UIView.animate(withDuration: 0.5, animations: {
                    toVC.view.backgroundColor = self.originalBackgroundColor
                    toVC.calendarView.backgroundColor = self.originalBackgroundColor
                }, completion: { success in
                    snapshot.removeFromSuperview()
                    backgroundView.removeFromSuperview()
                    transitionContext.completeTransition(false)
                })
            })
        }
    }
    
    func getOffsetBetween(originFrame origin: CGRect, window: CGRect, andFinalFrame finalFrame: CGRect, withXScaleX scaleX: CGFloat, andScaleY scaleY: CGFloat) -> CGPoint {
        // get the new offset whilst accounting for the new x and y scale values
        let offsetX = (origin.midX - window.midX) * scaleX
        let offsetY = (origin.midY - window.midY) * scaleY
        
        // get new window center based on offset amount
        let newX = window.midX - offsetX
        let newY = window.midY - offsetY - (finalFrame.midY + 50)
        
        let newPoint = CGPoint(x: newX, y: newY)
        
        return newPoint
    }
}
