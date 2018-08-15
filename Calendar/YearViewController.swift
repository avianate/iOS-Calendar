//
//  YearViewController.swift
//  Calendar
//
//  Created by Nate Graham on 8/13/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import UIKit

class YearViewController: UIViewController {

    @IBOutlet weak var calendarView: UICollectionView!
    
    var columns: CGFloat = 7
    var spacing: CGFloat = 10.0
    var inset: CGFloat = 10.0
    
    var cellWidth: CGFloat = 40
    var marginWidth: CGFloat = 30
    
    var calendars = [Year]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        calendarView.collectionViewLayout = YearCalendarCollectionLayout()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let date = dateFormatter.date(from: "2018/01/01")
        
        calendars.append(Year(date: date!))
        
        let frameWidth = view.frame.size.width
        let width = (frameWidth - (cellWidth * columns) - marginWidth) / columns
        let layout = calendarView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = width
        layout.sectionHeadersPinToVisibleBounds = false
        
//        calendarView.isPagingEnabled = true
    }
}

extension YearViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = calendarView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeader
        
        let section = Section()
        section.name = titleForSectionAt(indexPath: indexPath)
        
        view.section = section
        
        return view
    }
    
    func titleForSectionAt(indexPath: IndexPath) -> String {
        let month = calendars[0].months[indexPath.section]
        
        return month.name
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = calendarView.dequeueReusableCell(withReuseIdentifier: "CalendarDayCell", for: indexPath) as! DateCollectionViewCell
        let item = indexPath.item
        
        let currentYear = calendars[0]
        let section = indexPath.section
        let month = currentYear.months[section]
        
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
}

//extension YearViewController: UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsetsMake(inset, inset, inset, inset)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return CGFloat(10.0)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return spacing
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = Int((calendarView.frame.width / columns) - (inset + spacing))
//
//        return CGSize(width: width, height: width)
//    }
//}
