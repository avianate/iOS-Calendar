//
//  YearCalendarCollectionLayout.swift
//  Calendar
//
//  Created by Nate Graham on 8/15/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import UIKit

class YearCalendarCollectionLayout: UICollectionViewLayout {
    
    private var numberOfRows = 4
    private var numberOfSectionsInRow: CGFloat = 3
    private var numberOfDayColumns: CGFloat = 7
    private var numberOfSections = 12
    private var numberOfItems = 42
    
//    var itemWidth = collectionView.frame.width / numberOfSectionsInRow
//    var itemHeight = collectionView.frame.height / numberOfRows
    var sectionSize = CGSize(width: 125, height: 166)
    var itemSize = CGSize(width: 17, height: 23)
    var itemSpacing: CGFloat = 0
    
    var cellAttributes = [UICollectionViewLayoutAttributes]()
    var headerAttributes = [UICollectionViewLayoutAttributes]()
    
    // determiens the scrollView's width and height
    override var collectionViewContentSize: CGSize {
        let width = CGFloat(numberOfSectionsInRow * itemSize.width)
        let height = CGFloat(CGFloat(numberOfRows) * itemSize.height)
        
        return CGSize(width: width, height: height)
    }
    
    // prepares all of the cell sizing, spacing, and layout attributes for the data
    override func prepare() {
        
        guard let collectionView = collectionView else { return }
        
//        let availableHeight = Int(collectionView.bounds.height + itemSpacing)
//        let itemHeightForCalculation = Int(itemSize.height + itemSpacing)
        
        numberOfItems = collectionView.numberOfItems(inSection: 1)
        numberOfSections = collectionView.numberOfSections
        
        cellAttributes.removeAll()
        headerAttributes.removeAll()
        
        for monthIndex in 0 ..< numberOfSections {
            let row = monthIndex % numberOfRows
            let column = monthIndex / numberOfRows
            
            let headerIndexPath = IndexPath(item: row, section: monthIndex)
            let headerCellAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: headerIndexPath)
            headerAttributes.append(headerCellAttributes)
            headerCellAttributes.frame = CGRect(x: 0.0, y: CGFloat(column), width: itemSize.width, height: 8.0)
            
            // for each day in a month
            for dayIndex in 0 ..< numberOfItems {
                // get the width of day cell
                let cellWidth = itemSize.width
                let cellX = CGFloat(dayIndex) * itemSize.width
                let cellRow = CGFloat(dayIndex).truncatingRemainder(dividingBy: 7)
                let cellY = cellRow * itemSize.height
                
                // generate and store attributes for the cell
                let cellIndexPath = IndexPath(item: dayIndex, section: 1)
                let dayCellAttributes = UICollectionViewLayoutAttributes(forCellWith: cellIndexPath)
                
                cellAttributes.append(dayCellAttributes)
                dayCellAttributes.frame = CGRect(x: cellX, y: cellY, width: cellWidth, height: itemSize.height)
            }
            
        }
    }
    
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
//        guard let collectionView = collectionView else { return true }
//
//        let availableHeight = newBounds.height - collectionView.contentInset.top - collectionView.contentInset.bottom
//        let possibleRows = Int(availableHeight + itemSpacing) / Int(sectionSize.height + itemSpacing)
//
//        return possibleRows != numberOfRows
        
        return false
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes](headerAttributes)
        attributes += [UICollectionViewLayoutAttributes](cellAttributes)
        
        return attributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cellAttributes[indexPath.row]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return headerAttributes[indexPath.row]
    }
}
