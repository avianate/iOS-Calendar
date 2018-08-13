//
//  MonthCollectionView.swift
//  Calendar
//
//  Created by Nate Graham on 8/10/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import UIKit

class MonthCollectionView: UICollectionView {
    
    var monthNames: [String]?
    var veryShortWeekdayNames: [String]?
    var firstDayMonthStartsOn: Int?
    var numberOfDaysInMonth: Int?
    
    var today: Date?
    var currentDate: Date?
    var currentCalendar: Calendar?
    var currentMonth: Int?
    var currentMonthName: String?
    
    var currentDay: Int?
    var currentWeekday: Int?
    var currentWeekdayName: String?
    
    var currentYear: Int?
    
    // pass a month or day to constructor to retrun a collection for that month
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, collectionView: UICollectionView, date: Date) {
        super.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        
        self.currentCalendar = Calendar.autoupdatingCurrent
        self.today = Date()
        self.currentDate = date
        
        setupMonthView()
    }
    
    func setupMonthView() {
        guard let calendar = currentCalendar else { return }
        guard let currentDate = currentDate else { return }
        
        // set calendar components for day, month, year, etc.
        currentDay = calendar.component(.day, from: currentDate)
        currentWeekday = calendar.component(.weekday, from: currentDate)
        currentMonth = calendar.component(.month, from: currentDate)
        currentYear = calendar.component(.year, from: currentDate)
        
        // set the calendar month name
        currentMonthName = monthNames?[currentMonth! - 1]
        
        // set the first day that th emonth starts on and get the total number of days for the month
        firstDayMonthStartsOn = getFirstDayOfMonth(for: currentDate)
        numberOfDaysInMonth = getNumberOfDaysInMonth(for: currentDate)
    }
    
    func getFirstDayOfMonth(for date: Date) -> Int? {
        guard let calendar = currentCalendar else { return nil }
        
        let selectedDay = calendar.component(.day, from: date)
        
        if let firstDayOfMonthDate = calendar.date(byAdding: .day, value: -(selectedDay - 1), to: date) {
            return calendar.component(.weekday, from: firstDayOfMonthDate)
        }
        
        return nil
    }
    
    func getNumberOfDaysInMonth(for date: Date) -> Int? {
        guard let calendar = currentCalendar else { return nil }
        let numberOfDays = calendar.range(of: .day, in: .month, for: date)
        return numberOfDays?.count
    }
}

extension MonthCollectionView: UICollectionViewDelegate {
    
    override func numberOfItems(inSection section: Int) -> Int {
        return numberOfDaysInMonth != nil ? numberOfDaysInMonth! + 6 : 0
    }
    
    override func cellForItem(at indexPath: IndexPath) -> UICollectionViewCell? {
        let cell = dequeueReusableCell(withReuseIdentifier: "MonthDayCell", for: indexPath) as! DateCollectionViewCell

        let item = indexPath.item
        cell.dateLabel.text = ""
        
        if let firstDay = firstDayMonthStartsOn, let maxDays = numberOfDaysInMonth {
            
            // convert first day of month and number of days in month to zero-based like indexPath
            let firstDayOfMonth = firstDay - 1
            let numberOfDays = maxDays - 1
            let maxRows = firstDayOfMonth + numberOfDays
            let offset = firstDayOfMonth - 1
            
            // only show the dates starting on the correct weekday
            let canShowDate = item >= firstDayOfMonth && item <= maxRows
            
            if canShowDate {
                let dayNumber = item - offset
                cell.dateLabel.text = "\(dayNumber)"
            }
        }
        
        return cell
    }
}
