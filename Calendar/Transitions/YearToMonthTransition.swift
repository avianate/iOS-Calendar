//
//  YearToMonthTransition.swift
//  Calendar
//
//  Created by Nate Graham on 9/25/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import UIKit

class YearToMonthTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var monthViewIsPresenting = false
    var originalBackgroundColor: UIColor!
    var selectedMonthFrame: CGRect!
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
                transitionContext.completeTransition(false)
                return
        }

        let containerView = transitionContext.containerView
        
        let year = monthViewIsPresenting ? fromVC : toVC
        let yearVC = year as! YearViewController
        
        let month = monthViewIsPresenting ? toVC : fromVC
        let monthVC = month as! MonthViewController
        
        if monthViewIsPresenting {
            transitionToMonth(monthViewController: monthVC, yearViewController: yearVC, containerView: containerView, transitionContext: transitionContext)
            return
        }
        yearVC.scrollToYear()
        transitionToYear(monthViewController: monthVC, yearViewController: yearVC, containerView: containerView, transitionContext: transitionContext)
    }
    
    func transitionToYear(monthViewController monthVC: MonthViewController, yearViewController yearVC: YearViewController, containerView: UIView, transitionContext: UIViewControllerContextTransitioning) {
        containerView.addSubview(yearVC.view)
        containerView.bringSubviewToFront(monthVC.view)
        
        // get the start and end frame sizes
        let originFrame = monthVC.view.frame
        let finalFrame = yearVC.monthCellPositions![yearVC.monthToDisplay]
        
        let monthXScale = finalFrame.width / originFrame.width
        let monthYScale = finalFrame.height / originFrame.height
        
        yearVC.view.transform = .identity
        yearVC.calendarView.transform = .identity
        yearVC.view.alpha = 0.0
        
        // shrink view controller scale
        UIView.animate(withDuration: 0.5, animations: {
            // scale monthVC down
            monthVC.view.transform = CGAffineTransform(scaleX: monthXScale, y: monthYScale)
            // move to new point
            monthVC.view.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
            monthVC.view.alpha = 0.0
            yearVC.view.alpha = 1.0
        }, completion: { success in
            transitionContext.completeTransition(true)
        })

        // translate table view off screen
        // transition background color to white
        // transition to alpha 0.0
        
        // create yearVC snapshot
        // zoom snapshot
        // translate snapshot
        // transition alpha to 1.0
        
    }
    
    func transitionToMonth(monthViewController monthVC: MonthViewController, yearViewController yearVC: YearViewController, containerView: UIView, transitionContext: UIViewControllerContextTransitioning) {
        
        guard let snapshot = yearVC.view.snapshotView(afterScreenUpdates: false) else { return }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if let window = appDelegate.window, let selectedMonthCell = yearVC.selectedMonth {
            
            // create a throwaway frame so we don't see a black background during animation
            let frame = CGRect(x: 0.0, y: 0.0, width: window.frame.width, height: window.frame.height)
            let backgroundView = UIView(frame: frame)
            backgroundView.backgroundColor = .white
            containerView.addSubview(backgroundView)
            
            // add a snapshot which will be used for the animation
            containerView.addSubview(snapshot)
//            yearVC.removeFromParent()
            yearVC.view.alpha = 0.0
            
            // get the starting and ending frame sizes for the transition
            let originFrame = selectedMonthCell.superview?.convert(selectedMonthCell.frame, to: nil)
            let finalFrame = monthVC.calendarView.frame
            
            // get scale factor
            let xScaleFactor = window.frame.width / originFrame!.width
            let yScaleFactor =  finalFrame.height / originFrame!.height
            
            // set the initial scale for the month view controller
            let initialXScale = originFrame!.width / window.frame.width
            let initialYScale = originFrame!.height / window.frame.height
            
            // get new origin for the month view controller
            let newPoint = getOffsetBetween(originFrame: originFrame!, window: yearVC.calendarView.frame, andFinalFrame: finalFrame, withXScaleX: xScaleFactor, andScaleY: yScaleFactor)
            
            // setup initial state
            monthVC.view.alpha = 0.0
            self.originalBackgroundColor = monthVC.view.backgroundColor
            monthVC.view.backgroundColor = .white
            monthVC.calendarView.backgroundColor = .white
            monthVC.tableView.transform = CGAffineTransform(translationX: 0.0, y: window.frame.height)
            monthVC.view.transform = CGAffineTransform(scaleX: initialXScale, y: initialYScale)
            monthVC.view.center = CGPoint(x: originFrame!.midX, y: originFrame!.midY + 25)
            monthVC.calendarHeightConstraint.constant = originFrame!.height
            
            // don't forget to add the monthVC to the containerView
            containerView.addSubview(monthVC.view)
            containerView.bringSubviewToFront(monthVC.view)
            
            // animate to desired state
            UIView.animate(withDuration: 0.5, animations: {
                // set scale and origin to zoom into month cell
                snapshot.transform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
                snapshot.center = newPoint
                snapshot.alpha = 0.0
                
                // fade in monthViewController
                monthVC.view.alpha = 1.0
                // change backgroundColor back to original
                monthVC.tableView.transform = .identity
                monthVC.calendarHeightConstraint.constant = 240
                // zoom in and center
                monthVC.view.transform = .identity
                monthVC.view.center = CGPoint(x: window.frame.midX, y: window.frame.midY)
                
            }, completion: { success in
                // clean up
                UIView.animate(withDuration: 0.5, animations: {
                    // transition back to original background color
                    monthVC.view.backgroundColor = self.originalBackgroundColor
                    monthVC.calendarView.backgroundColor = self.originalBackgroundColor
                }, completion: { success in
                    // remove the snapshot and background view we created for this transition
                    snapshot.removeFromSuperview()
                    backgroundView.removeFromSuperview()
                    
                    transitionContext.completeTransition(true)
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
