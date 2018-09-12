//
//  MonthCollectionViewFlowLayout.swift
//  Calendar
//
//  Created by Nate Graham on 8/16/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import UIKit

class MonthCollectionViewFlowLayout: UICollectionViewLayout, UICollectionViewDelegateFlowLayout {
    
    private var columns: CGFloat = 7
    private var rows: CGFloat = 7
    private var interItemSpacing: CGFloat = 0
    private var lineSpacing: CGFloat = 0
    
    func setUpGrid(columns: CGFloat, rows: CGFloat, interItemSpacing: CGFloat, lineSpacing: CGFloat) {
        self.columns = columns
        self.rows = rows
        self.interItemSpacing = interItemSpacing
        self.lineSpacing = lineSpacing
    }
    
    func getCellWidth(_ collectionView: UICollectionView) -> CGFloat {
        
        let frameWidth = collectionView.frame.size.width
        let cellWidth = (frameWidth - (interItemSpacing * (columns - 1))) / columns
        
        return cellWidth
    }
    
    func getCellHeight(_ collectionView: UICollectionView) -> CGFloat {
        
        let frameHeight = collectionView.frame.size.height
        let cellHeight = (frameHeight - (lineSpacing * (rows - 1))) / rows
        
        return cellHeight
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let cellWidth = getCellWidth(collectionView)
        let totalCellWidth = cellWidth * columns
        //        let totalSpacing = (cellWidth * (columns - 1)) / 2
        let frameWidth = collectionView.frame.size.width
        
        let inset = (frameWidth - totalCellWidth) / 2
        
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = getCellWidth(collectionView)
        let cellHeight = getCellHeight(collectionView)
        
        let itemSize = CGSize(width: cellWidth, height: cellHeight)
        
        return itemSize
    }
}
