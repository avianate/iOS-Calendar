//
//  Month.swift
//  Calendar
//
//  Created by Nate Graham on 8/13/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import Foundation
import UIKit

class Month {
    var firstWeekday: Int = 0
    var lastWeekday: Int = 0
    var numberOfDays: Int = 0
    var name: String = ""
    var isCurrentMonth = false
    var isCurrentYear = false
    var isCurrentDay = false
    
    private let currentCalendar = UIKit.Calendar.autoupdatingCurrent
    private var today = Date()
    private var todayComponents: DateComponents!
    
    init(date: Date, forYear year: Int) {
        
        self.firstWeekday = getFirstDayOfMonth(forDate: date)
        self.lastWeekday = getLastWeekdayOfMonth(forDate: date)
        self.numberOfDays = getNumberOfDaysInMonth(forDate: date)
        self.name = getMonthName(forDate: date)
        
        todayComponents = currentCalendar.dateComponents([.year, .month, .day], from: today)
        self.isCurrentYear = year == todayComponents.year

        let monthComponents = currentCalendar.dateComponents([.year, .month], from: date)
        isCurrentMonth = todayComponents.month == monthComponents.month && isCurrentYear
    }
    
    func isCurrentDate(dayIndex day: Int) -> Bool {
        let currentDay = todayComponents.day
        let isCurrentDate = isCurrentYear && isCurrentMonth && currentDay == day
        return isCurrentDate
    }
    
    func getMonthName(forDate date: Date) -> String {
        let month = currentCalendar.component(.month, from: date)
        let monthName = currentCalendar.shortMonthSymbols[month - 1]
        
        return monthName
    }
    
    func getFirstDayOfMonth(forDate date: Date) -> Int {
        let day = currentCalendar.component(.day, from: date)
        var firstDayOfMonthDate = date
        
        if day > 1 {
            let dayOffset = -(day - 1)
            firstDayOfMonthDate = currentCalendar.date(byAdding: .day, value: dayOffset, to: date) ?? date
        }
        
        return currentCalendar.component(.weekday, from: firstDayOfMonthDate)
    }
    
    func getLastWeekdayOfMonth(forDate date: Date) -> Int {
        let lastDayOfMonth = getNumberOfDaysInMonth(forDate: date)
        let day = currentCalendar.component(.day, from: date)
        let offsetDays = day < lastDayOfMonth ? lastDayOfMonth - day : 0
        
        let adjustedDate = currentCalendar.date(byAdding: .day, value: offsetDays, to: date) ?? date
        
        let lastWeekdayInMonth = currentCalendar.component(.weekday, from: adjustedDate)
        
        return lastWeekdayInMonth
    }
    
    func getNumberOfDaysInMonth(forDate date: Date) -> Int {
        let numberOfDays = currentCalendar.range(of: .day, in: .month, for: date)
        
        return numberOfDays?.count ?? 30
    }
}
