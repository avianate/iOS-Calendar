//
//  SectionHeader.swift
//  Calendar
//
//  Created by Nate Graham on 8/13/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import UIKit

class SectionHeader: UICollectionReusableView {
    @IBOutlet private weak var nameLabel: UILabel!
    
    var section: Section! {
        didSet {
            nameLabel.text = section.name
        }
    }
    
    var isActive: Bool = false {
        didSet {
            if isActive {
                nameLabel.textColor = UIColor.red
            } else {
                nameLabel.textColor = UIColor.black
            }
        }
    }
}
