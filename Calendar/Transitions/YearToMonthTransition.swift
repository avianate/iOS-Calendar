//
//  YearToMonthTransition.swift
//  Calendar
//
//  Created by Nate Graham on 9/25/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import UIKit

class YearToMonthTransition: NSObject, UIViewControllerAnimatedTransitioning {
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
        containerView.addSubview(snapshot)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // get selected month cell
        if let window = appDelegate.window, let selectedMonth = fromVC.selectedMonth {
            let originFrame = selectedMonth.superview?.convert(selectedMonth.frame, to: nil)
            let finalFrame = toVC.calendarView.frame
            
            let xScaleFactor = window.frame.width / originFrame!.width
            // set scale factor
            let yScaleFactor = (window.frame.height / 2) / originFrame!.height
            // move origin
            print("month cell origin: \(selectedMonth.frame.origin), Bounds: \(selectedMonth.bounds.origin)")
            print("scale: \(xScaleFactor), \(yScaleFactor)")
            
            let newPoint = getOffsetBetween(originFrame: originFrame!, andWindow: fromVC.calendarView.frame, withXScaleX: xScaleFactor, andScaleY: yScaleFactor)
            
            UIView.animate(withDuration: 1.0, animations: {
                snapshot.transform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
                snapshot.center = newPoint
            }, completion: { success in
                UIView.animate(withDuration: 0.5, animations: {
                    print("new frame: \(snapshot.frame), \(snapshot.center)")
                    snapshot.transform = .identity
                }, completion: { success in
                    snapshot.removeFromSuperview()
                })
            })
        }
        
        
        transitionContext.completeTransition(false)
    }
    
    func getOffsetBetween(originFrame origin: CGRect, andWindow window: CGRect, withXScaleX scaleX: CGFloat, andScaleY scaleY: CGFloat) -> CGPoint {
        let cellMidX = origin.midX
        let cellMidY = origin.midY
        
        let frameMidX = window.midX
        let frameMidY = window.midY
        
        let offsetX = (cellMidX - frameMidX) * scaleX
        let offsetY = (cellMidY - frameMidY) * scaleY
        
        let newX = window.midX - offsetX
        let newY = window.midY - offsetY
        let newPoint = CGPoint(x: newX, y: newY)
        print("cell: \(origin.midX), \(origin.midY)")
        print("window: \(window.midX), \(window.midY)")
        print("offset: \(newPoint)")
        
        return newPoint
    }
}
