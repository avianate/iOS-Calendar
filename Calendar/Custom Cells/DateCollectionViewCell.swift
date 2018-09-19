//
//  DateCollectionViewCell.swift
//  Calendar
//
//  Created by Nate Graham on 8/2/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import UIKit

class DateCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var activeView: UIView!
    @IBOutlet weak var gigAccessory: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func showPartialGig(invertColor: Bool) {
        if invertColor {
            gigAccessory.image = UIImage(named: "gig_partial_white")
        } else {
            gigAccessory.image = UIImage(named: "gig_partial_black")
        }
        
        gigAccessory.isHidden = false
    }
    
    func showFullGig(invertColor: Bool) {
        if invertColor {
            gigAccessory.image = UIImage(named: "gig_full_white")
        } else {
            gigAccessory.image = UIImage(named: "gig_full_black")
        }
        
        gigAccessory.isHidden = false
    }
    
    func hidePartialGig() {
        gigAccessory.isHidden = true
    }
}
