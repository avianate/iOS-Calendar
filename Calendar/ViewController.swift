//
//  ViewController.swift
//  Calendar
//
//  Created by Nate Graham on 8/2/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - OUTLETS
    
    @IBOutlet weak var calendar: UICollectionView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var previousMonthLabel: UIButton!
    @IBOutlet weak var nextMonthLabel: UIButton!
    
    // MARK: - PROPERTIES
    
    var monthNames: [String]?
    var veryShortWeekdayNames: [String]?
    var shortWeekdayNames: [String]?
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
    
    var cellWidth: CGFloat = 40
    var marginWidth: CGFloat = 30
    
    // MARK: - ACTIONS
    
    @IBAction func nextMonth(_ sender: Any) {
        guard let date = currentDate else { return }
        
        currentDate = currentCalendar?.date(byAdding: .month, value: 1, to: date)
        calendarSetup()
        
        calendar.reloadData()
    }
    
    @IBAction func previousMonth(_ sender: Any) {
        guard let date = currentDate else { return }
        
        currentDate = currentCalendar?.date(byAdding: .month, value: -1, to: date)
        calendarSetup()
        
        calendar.reloadData()
    }
    
    // MARK: - VIEW METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let frameWidth = view.frame.size.width

        let width = (frameWidth - (cellWidth * 7) - marginWidth) / 7
        let layout = calendar.collectionViewLayout as! UICollectionViewFlowLayout
//        layout.itemSize = CGSize(width: width, height: 40)
        layout.minimumInteritemSpacing = width
//        layout.sectionHeadersPinToVisibleBounds = true
        
        // set today's date and set currentCalendar
        today = Date()
        currentDate = today
        currentCalendar = Calendar.autoupdatingCurrent
        calendarSetup()
    }
    
    override func viewWillLayoutSubviews() {
        let frameWidth = view.frame.size.width
        let width = (frameWidth - (cellWidth * 7) - marginWidth) / 7
        let layout = calendar.collectionViewLayout as! UICollectionViewFlowLayout
//        layout.itemSize = CGSize(width: width, height: 40)
        layout.minimumInteritemSpacing = width
        
        view.layoutIfNeeded()
    }
    
    // MARK: - CALENDAR METHODS
    func calendarSetup() {
        
        guard let calendar = currentCalendar else { return }
        guard let currentDate = currentDate else { return }
        
        // set calendar components for day, month, year, etc.
        currentDay = calendar.component(.day, from: currentDate)
        currentWeekday = calendar.component(.weekday, from: currentDate)
        currentMonth = calendar.component(.month, from: currentDate)
        currentYear = calendar.component(.year, from: currentDate)
        
        // set the calender month and weekday names
        monthNames = calendar.monthSymbols
        veryShortWeekdayNames = calendar.veryShortWeekdaySymbols
        shortWeekdayNames = calendar.shortWeekdaySymbols
        
        // set the current month and day names
        currentMonthName = monthNames?[currentMonth! - 1]
        currentWeekdayName = shortWeekdayNames?[currentWeekday! - 1]
        
        print("\n\(currentMonth!)/\(currentDay!)/\(currentYear!)")
        print("\(currentWeekdayName!) \(currentMonthName!) \(currentDay!), \(currentYear!)")
        
        // set the first day the month starts on and get the total number of days for the month
        firstDayMonthStartsOn = getFirstDayOfMonth(forDate: currentDate)
        numberOfDaysInMonth = getNumberOfDaysInMonth(forDate: currentDate)

        monthLabel.text = currentMonthName
        let previousMonth = currentMonth! >= 2 ? monthNames![currentMonth! - 2] : monthNames!.last
        let nextMonth = currentMonth! >= monthNames!.count - 1 ? monthNames!.first : monthNames![currentMonth!]
        
        previousMonthLabel.setTitle(previousMonth, for: .normal)
        nextMonthLabel.setTitle(nextMonth, for: .normal)
    }
    
    func getFirstDayOfMonth(forDate date: Date) -> Int? {
        guard let calendar = currentCalendar else { return nil }
        
        let selectedDay = calendar.component(.day, from: date)
        
        if let firstDayOfMonthDate = calendar.date(byAdding: .day, value: -1 * (selectedDay - 1), to: date) {
            return calendar.component(.weekday, from: firstDayOfMonthDate)
        }
        
        return nil
    }
    
    func getNumberOfDaysInMonth(forDate date: Date) -> Int? {
        guard let calendar = currentCalendar else { return nil }
        
        let numberOfDays = calendar.range(of: .day, in: .month, for: date)
        print("Number of days in month: \(numberOfDays!.count)")
        
        return numberOfDays?.count
    }
    
    func getMonthForSection(_ section: Int) {
//        return currentMonth
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: - COLLECTION VIEW METHODS

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 42
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 12
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = calendar.dequeueReusableCell(withReuseIdentifier: "CalendarDayCell", for: indexPath) as! DateCollectionViewCell
        let row = indexPath.row
        
        cell.dateLabel.text = ""
        
        let month = getMonthForSection(indexPath.section)
        
        if let firstDay = firstDayMonthStartsOn, let maxDays = numberOfDaysInMonth {
            
            // convert first day of month and number of days in month to zero-based like indexPath
            let firstDayOfMonth = firstDay - 1
            let numberOfDays = maxDays - 1
            let maxRows = firstDayOfMonth + numberOfDays
            let offset = firstDayOfMonth - 1
            
            // only show the dates starting on the correct weekday
            let canShowDate = row >= firstDayOfMonth && row <= maxRows
            
            
            if canShowDate {
                let dayNumber = row - offset
                cell.dateLabel.text = "\(dayNumber)"
            }
        }
        
        return cell
    }
}

