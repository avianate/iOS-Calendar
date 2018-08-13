//
//  CalendarViewController.swift
//  Calendar
//
//  Created by Nate Graham on 8/13/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var calendarView: UICollectionView!
    @IBOutlet weak var monthLabel: UILabel!
    
    var calendars = [Year]()
    var numberOfYearsToShow = 3
    
    var cellWidth: CGFloat = 40
    var marginWidth: CGFloat = 30

    override func viewDidLoad() {
        super.viewDidLoad()

        let frameWidth = view.frame.size.width
        let width = (frameWidth - (cellWidth * 7) - marginWidth) / 7
        let layout = calendarView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = width
        layout.sectionHeadersPinToVisibleBounds = false
        
        calendarView.isPagingEnabled = true
        
        setupCalendars()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrollToToday()
    }
    
    func scrollToToday() {
        let calendar = Calendar.autoupdatingCurrent
        let currentMonth = calendar.component(.month, from: Date())
        
        let indexPath = IndexPath(item: 0, section: currentMonth - 1)
        
        calendarView.scrollToItem(at: indexPath, at: .top, animated: false)
        
        updateMonthLabel(indexPath: indexPath)
    }
    
    func setupCalendars() {
        let today = Date()
        let calendar = Calendar.autoupdatingCurrent
        let currentYear = calendar.component(.year, from: today)
        
        var dateComponents = DateComponents()
        dateComponents.year = currentYear
        dateComponents.month = 1
        dateComponents.day = 1
        
        for i in 1 ... numberOfYearsToShow {
            dateComponents.year = i < 2
                                    ? currentYear - 1
                                    : i > 2
                                        ? currentYear + 1
                                        : currentYear
            
            if let dateForYear = calendar.date(from: dateComponents) {
                let year = Year(date: dateForYear)
                calendars.append(year)
            }
        }
    }
    
    func updateMonthLabel(indexPath: IndexPath) {
        let month = calendars[1].months[indexPath.section]
        
        monthLabel.text = month.name
    }
    
    func updateMonthLabel() {
        let indexPath = calendarView.indexPathsForVisibleItems.first
        let month = calendars[1].months[indexPath?.section ?? 0]
        
        monthLabel.text = month.name
    }
}

extension CalendarViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = calendarView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeader
        
        let section = Section()
        section.name = titleForSectionAt(indexPath: indexPath)
        
        view.section = section
        
        return view
    }
    
    func titleForSectionAt(indexPath: IndexPath) -> String {
        let month = calendars[1].months[indexPath.section]
        
        return month.name
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateMonthLabel()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = calendarView.dequeueReusableCell(withReuseIdentifier: "CalendarDayCell", for: indexPath) as! DateCollectionViewCell
        let item = indexPath.item
        
        let currentYear = calendars[1]
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
