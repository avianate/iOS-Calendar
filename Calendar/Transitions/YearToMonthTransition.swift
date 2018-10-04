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
        containerView.backgroundColor = UIColor.white
        
        // get the start and end frame sizes
        let originFrame = monthVC.view.frame
        let finalFrame = yearVC.monthCellPositions![yearVC.monthToDisplay]
        let originalCenter = yearVC.view.center
        
        let monthXScale = finalFrame.width / originFrame.width
        let monthYScale = finalFrame.height / originFrame.height
        
        let yearXScale = originFrame.width / finalFrame.width
        let yearYScale = (originFrame.height / 2) / finalFrame.height
        
        let newPoint = getOffsetBetween(originFrame: originFrame, andFinalFrame: finalFrame, withXScale: yearXScale, andYScale: yearYScale)
        
        yearVC.view.transform = .identity
        yearVC.calendarView.transform = .identity
        yearVC.view.alpha = 0.0
        yearVC.view.transform = CGAffineTransform(scaleX: yearXScale, y: yearYScale)
        yearVC.view.center = newPoint
        
        // shrink view controller scale
        UIView.animate(withDuration: 0.5, animations: {
            // scale monthVC down
            monthVC.view.transform = CGAffineTransform(scaleX: monthXScale, y: monthYScale)
            // move to new point
            monthVC.view.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY + 50)
            monthVC.view.alpha = 0.0
            monthVC.view.backgroundColor = UIColor.white
            monthVC.calendarView.backgroundColor = UIColor.white
            monthVC.tableView.transform = CGAffineTransform(translationX: 0.0, y: containerView.frame.height * 4)
            
            yearVC.view.alpha = 1.0
            yearVC.view.transform = .identity
            yearVC.view.center = originalCenter
        }, completion: { success in
            transitionContext.completeTransition(true)
        })
    }
    
    func transitionToMonth(monthViewController monthVC: MonthViewController, yearViewController yearVC: YearViewController, containerView: UIView, transitionContext: UIViewControllerContextTransitioning) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if let window = appDelegate.window, let selectedMonthCell = yearVC.selectedMonth {
            
            // set the container view's background color to white just to be safe
            containerView.backgroundColor = .white
            
            // get the starting and ending frame sizes for the transition
            let originFrame = selectedMonthCell.superview?.convert(selectedMonthCell.frame, to: nil)
            let finalFrame = monthVC.calendarView.frame
            
            // get scale factor
            let xScaleFactor = finalFrame.width / originFrame!.width
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
                yearVC.view.transform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
                yearVC.view.center = newPoint
                yearVC.view.alpha = 0.0
                
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
                    // reset the yearVC transform or it will be messed up when comming back from the month
                    yearVC.view.transform = .identity
                    
                    transitionContext.completeTransition(true)
                })
            })
        }
    }
    
    // gets the offset between the originFrame, the window, and the finalFrame accounting for the x and y scale values
    func getOffsetBetween(originFrame origin: CGRect, window: CGRect, andFinalFrame finalFrame: CGRect, withXScaleX scaleX: CGFloat, andScaleY scaleY: CGFloat) -> CGPoint {
        // get the new offset whilst accounting for the new x and y scale values
        let offsetX = (origin.midX - window.midX) * scaleX
        let offsetY = (origin.midY - window.midY) * scaleY
        
        // get new window center based on offset amount
        let newX = window.midX - offsetX
        let newY = window.midY - offsetY - (finalFrame.midY + 50) // adjust for day label height
        
        let newPoint = CGPoint(x: newX, y: newY)
        
        return newPoint
    }
    
    // gets the offset from the current monthVC center and the yearVC month cell's center while accounting for the x and y yearVC scale values
    func getOffsetBetween(originFrame origin: CGRect, andFinalFrame final: CGRect, withXScale scaleX: CGFloat, andYScale scaleY: CGFloat) -> CGPoint {
        let offsetX = (origin.midX - final.midX + 50) * scaleX
        let offsetY = (origin.midY - final.midY + 50) * scaleY
        
        let newPoint = CGPoint(x: offsetX, y: offsetY)
        
        return newPoint
    }
}
