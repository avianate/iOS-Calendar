//
//  TransitionCoordinator.swift
//  Calendar
//
//  Created by Nate Graham on 9/25/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import UIKit

class TransitionCoordinator: NSObject, UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return YearToMonthTransition()
    }
    
}
