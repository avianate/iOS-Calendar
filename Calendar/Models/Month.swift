//
//  Month.swift
//  Calendar
//
//  Created by Nate Graham on 8/13/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Month {
    var firstWeekday: Int = 0
    var lastWeekday: Int = 0
    var numberOfDays: Int = 0
    var name: String = ""
    var isCurrentMonth = false
    var isCurrentYear = false
    var isCurrentDay = false
    var month: Int = 0
    var day: Int = 0
    var year: Int = 0
    
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
        
        let monthComponents = currentCalendar.dateComponents([.year, .month, .day], from: date)
        isCurrentMonth = todayComponents.month == monthComponents.month && isCurrentYear
        
        if let month = monthComponents.month, let day = monthComponents.day, let year = monthComponents.year {
            self.month = month
            self.day = day
            self.year = year
        }
    }
    
    
    // TODO: refactor the initializers to not duplicate the same code
    init(date: Date) {
        self.firstWeekday = getFirstDayOfMonth(forDate: date)
        self.lastWeekday = getLastWeekdayOfMonth(forDate: date)
        self.numberOfDays = getNumberOfDaysInMonth(forDate: date)
        self.name = getMonthName(forDate: date)
        
        todayComponents = currentCalendar.dateComponents([.year, .month, .day], from: today)
        let dateYear = currentCalendar.dateComponents([.year], from: date)
        self.isCurrentYear = dateYear.year == todayComponents?.year
        
        let monthComponents = currentCalendar.dateComponents([.year, .month, .day], from: date)
        isCurrentMonth = todayComponents.month == monthComponents.month && isCurrentYear
        
        if let month = monthComponents.month, let day = monthComponents.day, let year = monthComponents.year {
            self.month = month
            self.day = day
            self.year = year
        }
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
    
    func getMonth(forDate date: Date) -> Int {
        let month = currentCalendar.component(.month, from: date)
        return month
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
    
    func getData(forDate date: Date) -> Gig? {
        
        // return model data for specified date
        
        // 1 get the managed context from the app delegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2 create fetch request for all "Gig" entities
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Gig")
        let dateString = date.toString()
        let predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", dateString, dateString)
        
        fetchRequest.predicate = predicate
        
        // 3 execute fetch request
        do {
            let data = try managedContext.fetch(fetchRequest)
            return data.first as? Gig
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return nil
    }
    
    func getDateFrom(components: DateComponents) -> Date? {
        return currentCalendar.date(from: components)
    }
}
