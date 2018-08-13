//
//  SectionHeader.swift
//  Calendar
//
//  Created by Nate Graham on 8/13/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import UIKit

class SectionHeader: UICollectionReusableView {
    @IBOutlet private weak var monthNameLabel: UILabel!
    
    var section: Section! {
        didSet {
            monthNameLabel.text = section.name
        }
    }
}
