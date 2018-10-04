//
//  MonthViewController.swift
//  LDSChorister
//
//  Created by Nate Graham on 9/6/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import Foundation
import UIKit

extension MonthViewController {
    
    // MARK: - COLLECTION VIEW HELPERS
    
    /// Used to set the scroll view to the selected month
    func setScrollOffset() {
        let section = selectedYear!
        let item = selectedMonth!
        let previousMonths = CGFloat((section * 12) + item)
        let pageSize = calendarView.bounds.size.height + 40
        let offset = CGPoint(x: 0, y: (pageSize * previousMonths) + 40)
        calendarView.setContentOffset(offset, animated: false)
    }
    
    /// updates back button to the currently displayed month when scrolling
    ///
    /// - Parameter indexPath: The IndexPath
    func updateMonthLabel(indexPath: IndexPath) {
        let month = months[indexPath.section]
        
        let buttonTitle = "\(month.name)"
        delegate?.backButtonDidChange(title: buttonTitle)
    }
    
    /// updates back button to the currently displayed month when scrolling
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
    
    /// gets the year for the currently visible month
    ///
    /// - Returns: The year as a String
    func getYearForMonth() -> String {
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
    
    /// gets year for the visible month
    ///
    /// - Returns: The integer value of the year
    func getVisibleYear() -> Int {
        let indexPath = calendarView.indexPathsForVisibleItems.first
        let month = indexPath?.section
        if let month = month {
            return month < 12 ? 0 : month < 24 ? 1 : 2
        }
        
        return 1
    }
    
    func getVisibleMonth() -> Int {
        let indexPath = calendarView.indexPathsForVisibleItems.first
        let month = indexPath?.section
        if let month = month {
            return month % 12
        }
        
        return 0
    }
    
    // determines the number of days to offset for the first day of the month
    // e.g. if the first day is saturday, the offset is 6
    
    /// determines the number of days to offset for the first day of the month
    /// e.g. if the first day is saturday, the offset is 6
    ///
    /// - Parameter month: Month to be displayed
    /// - Returns: Int representing the number of days to skip
    func getOffsetDays(forMonth month: Month) -> Int {
        let firstDayOfMonth = month.firstWeekday - 1
        let offset = firstDayOfMonth - 1
        
        return offset
    }
    
    // return a string for the day number cell in the collection view
    
    /// Get the day number for the cell
    ///
    /// - Parameters:
    ///   - month: the month being rendered
    ///   - indexPath: the index path for the cell (day)
    /// - Returns: String value of the day number
    func getCellDayNumber(forMonth month: Month, withIndexPath indexPath: IndexPath) -> String {
        
        let item = indexPath.item
        
        // convert first day of month and number of days in month to be zero-based numbers
        let firstDayOfMonth = month.firstWeekday - 1
        let numberOfDays = month.numberOfDays - 1
        let maxItems = firstDayOfMonth + numberOfDays
        let offset = getOffsetDays(forMonth: month)
        
        // only show the dates starting on the correct weekday
        let canShowDate = item >= firstDayOfMonth && item <= maxItems
        
        if canShowDate {
            let dayNumber = item - offset
            return "\(dayNumber)"
        }
        
        return ""
    }
    
    /// sets the date text color (red for sundays and today) for all cells
    /// and sets the accessory view for the selected date cell
    ///
    /// - Parameters:
    ///   - cell: DateCollectionViewCell
    ///   - month: month
    ///   - day: day
    ///   - offset: number of days to offset
    ///   - indexPath: indexPath
    ///   - isSelected: is the cell currently selected
    func setTextColorAndSelection(forCell cell: DateCollectionViewCell, withMonth month: Month, day: Int, offset: Int = 0, andIndex indexPath: IndexPath, isSelected: Bool = false) {
        
        let isCurrentDate = month.isCurrentDate(dayIndex: day - offset)
        
        if let previousIndex = previouslySelectedCellIndex {
            
            if let previousCell = calendarView.cellForItem(at: previousIndex) as? DateCollectionViewCell {
                
                previousCell.activeView.isHidden = true
                
                // get the cell's day as an int
                let day = getDay(fromCell: previousCell)
                
                // if the previously selected cell is today's date
                let previousIsToday = month.isCurrentDate(dayIndex: day - offset)
                let previousIsSunday = isSunday(previousIndex)
                let isRed = previousIsToday || previousIsSunday
                
                // set it's text color back to black
                previousCell.dateLabel.textColor = isRed ? UIColor.red : UIColor.black
                let dateComponents = DateComponents(year: month.year, month: month.month, day: day)
                let date = month.getDateFrom(components: dateComponents)
                setGigAccessory(forCell: previousCell, ofDate: date!)
            }
        }
        
        // make sunday cells and today's date have red numbers
        if !isSelected && (isSunday(indexPath) || isCurrentDate) {
            cell.dateLabel.textColor = UIColor.red
        } else {
            cell.dateLabel.textColor = UIColor.black
        }
        
        // if the cell is selected, set the text color to white
        if isSelected {
            let activeView = cell.activeView
            activeView?.isHidden = false
            activeView?.layer.cornerRadius = 4
            activeView?.layer.masksToBounds = true
            cell.dateLabel.textColor = UIColor.white
            
            // if the selected cell isn't todays date, the accessory will be black, otherwise it's red
            if !isCurrentDate {
                cell.activeView.backgroundColor = UIColor.black
            } else {
                cell.activeView.backgroundColor = UIColor.red
            }
        }
    }
    
    func setGigAccessory(forCell cell: DateCollectionViewCell, ofDate date: Date) {
        let isSelected = cell.isSelected
        let color = isSelected ? "white" : "black"
        let modifier = isPartialGig(date) ? "partial" : "full"
        let hasGigOnDate = hasGig(onDate: date)
        
        if hasGigOnDate {
            cell.gigAccessory.image = UIImage(named: "gig_\(modifier)_\(color)_5x5")
        }
        
        cell.gigAccessory.isHidden = !hasGigOnDate
    }
    
    func hasGig(onDate date: Date) -> Bool {
        
        let month = Month(date: date)
        let gig = month.getData(forDate: date)
        
        return gig != nil
    }
    
    func isPartialGig(_ date: Date) -> Bool {
        let month = Month(date: date)

        if let gig = month.getData(forDate: date) {
            let hasVenue = gig.venue != nil
            let hasOpener = gig.openingSong != nil
            let hasCloser = gig.closingSong != nil
            let hasEncore = gig.encoreSong != nil
            
            return !hasVenue || !hasOpener || !hasCloser || !hasEncore
        }
        
        return false
    }
    
    /// Determines if the cell being rendered is a sunday
    ///
    /// - Parameter indexPath: indexPath
    /// - Returns: true if is sunday
    func isSunday(_ indexPath: IndexPath) -> Bool {
        
        if indexPath.item % 7 == 0 {
            return true
        }
        
        return false
    }
    
    /// gets the day number from the text value in the cell
    ///
    /// - Parameter cell: DateCollectionViewCell
    /// - Returns: Int
    func getDay(fromCell cell: DateCollectionViewCell) -> Int {
        return Int(cell.dateLabel.text!) ?? 0
    }
    
    /// gets the month number (1 – 12) from the indexPath section
    ///
    /// - Parameter section: indexPath section
    /// - Returns: Int
    func getMonthInYear(fromSection section: Int) -> Int {
        return section % 12 + 1
    }
    
    /// gets the year from the indexPath section
    ///
    /// - Parameter section: indexPath section
    /// - Returns: Int
    func getYear(forSection section: Int) -> Int {
        return section < 12
            ? calendars[0].year
            : section < 24
            ? calendars[1].year
            : calendars[2].year
    }
    
    // fetches any meeting data for the selected date and reloads the tableView
    
    /// fetches any meeting data for the selected date and reloads the tableView
    ///
    /// - Parameters:
    ///   - section: inxexPath section
    ///   - day: day number
    func loadMeetingDataForDate(fromSection section: Int, andDay day: Int) {
        
        let month = months[section]
        let monthInYear = getMonthInYear(fromSection: section)
        let year = getYear(forSection: section)
        
        let dateComponents = DateComponents(year: year, month: monthInYear, day: day)
        let date = month.getDateFrom(components: dateComponents)
        
        if let date = date {
            gigForDate = month.getData(forDate: date)
        } else {
            gigForDate = nil
        }
        
        tableView.reloadData()
    }
}
