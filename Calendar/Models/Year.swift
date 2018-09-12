//
//  Month.swift
//  Calendar
//
//  Created by Nate Graham on 8/13/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import Foundation
import UIKit

struct CalendarData {
    
    var today = Date()
    
    var currentYear: Int {
        return getComponentsForToday().year!
    }
    
    var currentMonth: Int {
        return getComponentsForToday().month!
    }
    
    var currentDay: Int {
        return getComponentsForToday().day!
    }
    
    private let calendar = UIKit.Calendar.autoupdatingCurrent
    
    var calendars = [Calendar]()
    
    
    func getComponentsForToday() -> DateComponents {
        return getComponentsForDate(date: today)
    }
    
    func getComponentsForDate(date: Date) -> DateComponents {
        return calendar.dateComponents([.year, .month, .day], from: date)
    }
}
