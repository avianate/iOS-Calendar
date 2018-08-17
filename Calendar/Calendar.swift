//
//  Calendar.swift
//  Calendar
//
//  Created by Nate Graham on 8/16/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import UIKit

class Calendar {
    
    private var components: DateComponents!
    private let uiCalendar = UIKit.Calendar.autoupdatingCurrent
    private let today = Date()
    private var todayComponents: DateComponents {
        return uiCalendar.dateComponents([.year, .month, .day], from: today)
    }
    
    var year: Int {
        return components.year!
    }
    
    var month: Int {
        return components.month!
    }
    
    var day: Int {
        return components.day!
    }
    
    var isCurrentYear: Bool {
        return todayComponents.year == year
    }
    
    var isCurrentMonth: Bool {
        return todayComponents.month == month
    }
    var isCurrentDay: Bool {
        return todayComponents.day == day
    }
    
    var months = [Month]()
    
    init(date: Date = Date()) {
        self.components = uiCalendar.dateComponents([.year, .month, .day], from: date)
        
        for i in 0 ..< 12 {
            if let newDate = uiCalendar.date(byAdding: .month, value: i, to: date) {
                let month = Month(date: newDate, forYear: components.year!)
                months.append(month)
            }
        }
    }
}
