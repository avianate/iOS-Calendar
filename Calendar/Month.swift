//
//  Month.swift
//  Calendar
//
//  Created by Nate Graham on 8/13/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import Foundation

class Month {
    var firstWeekday: Int = 0
    var lastWeekday: Int = 0
    var numberOfDays: Int = 0
    var name: String = ""
    
    private let calendar: Calendar
    
    init(date: Date) {
        self.calendar = Calendar.autoupdatingCurrent
        
        self.firstWeekday = getFirstDayOfMonth(forDate: date)
        self.lastWeekday = getLastWeekdayOfMonth(forDate: date)
        self.numberOfDays = getNumberOfDaysInMonth(forDate: date)
        self.name = getMonthName(forDate: date)
    }
    
    func getMonthName(forDate date: Date) -> String {
        let month = calendar.component(.month, from: date)
        let monthName = calendar.monthSymbols[month - 1]
        
        return monthName
    }
    
    func getFirstDayOfMonth(forDate date: Date) -> Int {
        let day = calendar.component(.day, from: date)
        var firstDayOfMonthDate = date
        
        if day > 1 {
            let dayOffset = -(day - 1)
            firstDayOfMonthDate = calendar.date(byAdding: .day, value: dayOffset, to: date) ?? date
        }
        
        return calendar.component(.weekday, from: firstDayOfMonthDate)
    }
    
    func getLastWeekdayOfMonth(forDate date: Date) -> Int {
        let lastDayOfMonth = getNumberOfDaysInMonth(forDate: date)
        let day = calendar.component(.day, from: date)
        let offsetDays = day < lastDayOfMonth ? lastDayOfMonth - day : 0
        
        let adjustedDate = calendar.date(byAdding: .day, value: offsetDays, to: date) ?? date
        
        let lastWeekdayInMonth = calendar.component(.weekday, from: adjustedDate)
        
        return lastWeekdayInMonth
    }
    
    func getNumberOfDaysInMonth(forDate date: Date) -> Int {
        let numberOfDays = calendar.range(of: .day, in: .month, for: date)
        
        return numberOfDays?.count ?? 30
    }
}
