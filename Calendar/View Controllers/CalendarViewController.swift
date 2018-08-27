//
//  CalendarViewController.swift
//  Calendar
//
//  Created by Nate Graham on 8/13/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import UIKit

protocol MonthViewDelegate: class {
    func backButtonDidChange(title: String)
    func yearToDisplay(_ year: Int)
}

class MonthViewController: UIViewController {
    
    @IBOutlet weak var calendarView: UICollectionView!
    
    var calendars = [Calendar]()
    var months = [Month]()
    var numberOfYearsToShow = 3
    var selectedYear: Int?
    var selectedMonth: Int?
    
    var cellWidth: CGFloat = 40
    var marginWidth: CGFloat = 30
    var finishedInitialLayout = false;
    
    weak var delegate: MonthViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let selectedMonth = selectedMonth, let selectedYear = selectedYear, months.count > 0 {
            let monthIndex = (selectedYear * 12) + selectedMonth
            let month = months[monthIndex]
            let buttonTitle = "\(month.name)"
            delegate?.backButtonDidChange(title: buttonTitle)
            
        }
        
        self.dismiss(animated: true, completion: nil)
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        let year = getVisibleYear()
        delegate?.yearToDisplay(year)
    }
    
    override func viewDidLayoutSubviews() {
        
        if !finishedInitialLayout {
            if selectedYear != nil && selectedMonth != nil {
                setScrollOffset()
                if calendarView.contentOffset.y > 0 {
                    finishedInitialLayout = true;
                }
            }
        }
    }
    
    private func setScrollOffset() {
        let section = selectedYear!
        let item = selectedMonth!
        let previousMonths = CGFloat((section * 12) + item)
        let pageSize = calendarView.bounds.size.height + 40
        let offset = CGPoint(x: 0, y: (pageSize * previousMonths) + 40)
        calendarView.setContentOffset(offset, animated: false)
    }
    
    func updateMonthLabel(indexPath: IndexPath) {
        let month = months[indexPath.section]
        
        let buttonTitle = "\(month.name)"
        delegate?.backButtonDidChange(title: buttonTitle)
    }
    
    func updateMonthLabel() {
        
        if !finishedInitialLayout, let selectedYear = selectedYear, let selectedMonth = selectedMonth {
            let month = calendars[selectedYear].months[selectedMonth]
            
            let buttonTitle = "\(month.name) \(calendars[selectedYear].year)"
            delegate?.backButtonDidChange(title: buttonTitle)
            
            
            return
        }
        
        guard let indexPath = calendarView.indexPathsForVisibleItems.first else { return }
        let month = months[indexPath.section]
        let buttonTitle = "\(month.name) \(getYearForMonth())"
        delegate?.backButtonDidChange(title: buttonTitle)
    }
    
    private func getYearForMonth() -> String {
        var result = ""
        
        let indexPath = calendarView.indexPathsForVisibleItems.first
        let month = indexPath?.section
        if let month = month {
            let year = month < 12
                        ? calendars.first?.year
                        : month >= 12 && month < 24
                                ? calendars[1].year
                                : calendars.last?.year
            
            if year != nil {
                result = "\(year!)"
            }
        }
        
        return result
    }
    
    private func getVisibleYear() -> Int {
        let indexPath = calendarView.indexPathsForVisibleItems.first
        let month = indexPath?.section
        if let month = month {
            return month < 12 ? 0 : month < 24 ? 1 : 2
        }
        
        return 1
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
