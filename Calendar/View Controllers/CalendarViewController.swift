//
//  CalendarViewController.swift
//  Calendar
//
//  Created by Nate Graham on 8/13/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import UIKit

class MonthViewController: UIViewController {
    
    @IBOutlet weak var calendarView: UICollectionView!
    @IBOutlet weak var monthLabel: UILabel!
    
    var calendars = [Calendar]()
    var months = [Month]()
    var numberOfYearsToShow = 3
    var selectedYear: Int?
    var selectedMonth: Int?
    
    var cellWidth: CGFloat = 40
    var marginWidth: CGFloat = 30
    var finishedInitialLayout = false;

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Layout cells
        let frameWidth = view.frame.size.width
        let width = (frameWidth - (cellWidth * 7) - marginWidth) / 7
        let layout = calendarView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = width
        layout.sectionHeadersPinToVisibleBounds = false
        
        if calendars.count > 0 {
            for calendar in calendars.enumerated() {
                months.append(contentsOf: calendar.element.months)
            }
            
            print("Months count: \(months.count)")
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        if !finishedInitialLayout {
            if selectedYear != nil && selectedMonth != nil {
                let section = selectedYear!
                let item = selectedMonth!
                let previousMonths = CGFloat((section * 12) + item)
                let pageSize = calendarView.bounds.size.height - 10
                let offset = CGPoint(x: 0, y: (pageSize * previousMonths) + 40)
                calendarView.setContentOffset(offset, animated: false)
                
                if calendarView.contentOffset.y > 0 {
                    finishedInitialLayout = true;
                }
            }
        }
    }
    
//
//    func scrollToToday() {
//        let calendar = UIKit.Calendar.autoupdatingCurrent
//        let currentMonth = calendar.component(.month, from: Date())
//
//        let indexPath = IndexPath(item: 0, section: currentMonth - 1)
//
//        calendarView.scrollToItem(at: indexPath, at: .top, animated: false)
//
//        updateMonthLabel(indexPath: indexPath)
//    }
//
//    func setupCalendars() {
//        let today = Date()
//        let calendar = UIKit.Calendar.autoupdatingCurrent
//        let currentYear = calendar.component(.year, from: today)
//
//        var dateComponents = DateComponents()
//        dateComponents.year = currentYear
//        dateComponents.month = 1
//        dateComponents.day = 1
//
//        for i in 1 ... numberOfYearsToShow {
//            dateComponents.year = i < 2
//                                    ? currentYear - 1
//                                    : i > 2
//                                        ? currentYear + 1
//                                        : currentYear
//
//            if let dateForYear = calendar.date(from: dateComponents) {
//                let year = Calendar(date: dateForYear)
//                calendars.append(year)
//            }
//        }
//    }
//
    func updateMonthLabel(indexPath: IndexPath) {
        let month = months[indexPath.section]

        monthLabel.text = month.name
    }
    
    func updateMonthLabel() {
//        let indexPath = calendarView.indexPathsForVisibleItems.first
        
        if !finishedInitialLayout, let selectedYear = selectedYear, let selectedMonth = selectedMonth {
            let month = calendars[selectedYear].months[selectedMonth]
            monthLabel.text = month.name
            
            return
        }
        
        guard let indexPath = calendarView.indexPathsForVisibleItems.first else { return }
        let month = months[indexPath.section]
        monthLabel.text = month.name
    }
}

extension MonthViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = calendarView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeader
        
        let section = Section()
        section.name = titleForSectionAt(indexPath: indexPath)
        
        view.section = section
        return view
    }
    
    func titleForSectionAt(indexPath: IndexPath) -> String {
        let month = months[indexPath.section]
        
        return month.name
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateMonthLabel()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return months.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = calendarView.dequeueReusableCell(withReuseIdentifier: "CalendarDayCell", for: indexPath) as! DateCollectionViewCell
        let item = indexPath.item
        
//        let currentYear = calendars[]
        let section = indexPath.section
        let month = months[section]
        
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
