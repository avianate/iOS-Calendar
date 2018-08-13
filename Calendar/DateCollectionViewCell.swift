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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
