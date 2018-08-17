//
//  MonthCollectionViewCell.swift
//  Calendar
//
//  Created by Nate Graham on 8/15/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import UIKit

class MonthCollectionViewCell: UICollectionViewCell {
    
    var month: Month!
    
    private let columns: CGFloat = 7
    private let rows: CGFloat = 7
    private let cellSpacing: CGFloat = 0
    private let interItemSpacing: CGFloat = 0
    private let lineSpacing: CGFloat = 0
    private let minimumHeight: CGFloat = 144.5
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        collectionView.isScrollEnabled = false
    }
    
    func invalidateLayout() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func update() {
        collectionView.reloadData()
    }
}

extension MonthCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as! DateCollectionViewCell
        let item = indexPath.item
        
        cell.dateLabel.textColor = UIColor.black
        
        let isCurrentDate = month.isCurrentDate(dayIndex: indexPath.item)
        if isCurrentDate, let activeView = cell.activeView {
            activeView.isHidden = false
            activeView.layer.cornerRadius = 4
            activeView.layer.masksToBounds = true
            cell.dateLabel.textColor = UIColor.white
        } else {
            cell.activeView.isHidden = true
        }
        
        cell.dateLabel.text = ""

        // convert first day of month and number of days in month to be zero-based numbers
        let firstDayOfMonth = month.firstWeekday - 1
        let numberOfDays = month.numberOfDays - 1
        let maxItems = firstDayOfMonth + numberOfDays
        let offset = firstDayOfMonth - 1

        // only show the dates starting on the correct weekday
        let canShowDate = item >= firstDayOfMonth && item <= maxItems

        if canShowDate {
            let dayNumber = item - offset
            cell.dateLabel.text = "\(dayNumber)"
        }
        
        return cell
    }
    
//    func isCurrentDay(_ indexPath: IndexPath) {
//        let today = Date()
//        let todayComponents = Calendar.autoupdatingCurrent.dateComponents([.month, .day], from: today)
//    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MonthHeader", for: indexPath) as! SectionHeader
        
        let section = Section()
        section.name = month.name
        
        view.section = section
        view.isActive = month.isCurrentMonth
        
        return view
    }
    
//    func setupGrid() {
//        
//        let frameWidth = collectionView.frame.size.width
//        let frameHeight = collectionView.frame.size.width
//        let cellWidth = (frameWidth - (interItemSpacing * (columns - 1))) / columns
//        let cellHeight = (frameHeight - (lineSpacing * (rows - 1))) / rows
//        
//        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
//        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
//        layout.minimumInteritemSpacing = interItemSpacing
//        layout.minimumLineSpacing = lineSpacing
//    }
}

extension MonthCollectionViewCell: UICollectionViewDelegateFlowLayout {
    
    func getCellWidth() -> CGFloat {
        
        let frameWidth = collectionView.frame.size.width
        let cellWidth = (frameWidth - (interItemSpacing * (columns - 1))) / columns
        
        return cellWidth
    }
    
    func getCellHeight() -> CGFloat {
        
        let frameHeight = collectionView.frame.size.height
        let cellHeight = (frameHeight - (lineSpacing * (rows - 1))) / rows
        
        return cellHeight
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        let minimumHeight: CGFloat = 144.5
//
//        let cellWidth = getCellWidth()
//        let totalCellWidth = cellWidth * columns
//        let totalSpacing = (cellWidth * (columns - 1)) / 2
//        let frameWidth = collectionView.frame.size.width
//
//        let inset = (frameWidth - totalCellWidth) / 2
//
//        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = getCellWidth()
        let cellHeight = getCellHeight()
        
        let itemSize = CGSize(width: cellWidth, height: cellHeight)
        
        return itemSize
    }
}
