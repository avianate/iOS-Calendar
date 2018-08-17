//
//  Month.swift
//  Calendar
//
//  Created by Nate Graham on 8/13/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import Foundation
import UIKit

//struct Year {
//    let year: Int
//    var months = [Month]()
//    var isCurrentYear = false
//
//    init(date: Date) {
//        let calendar = Calendar.autoupdatingCurrent
//
//        self.year = calendar.component(.year, from: date)
//
//        let currentYear = calendar.component(.year, from: Date())
//        isCurrentYear = currentYear == self.year
//
//        for i in 0 ..< 12 {
//            if let newDate = calendar.date(byAdding: .month, value: i, to: date) {
//                let month = Month(date: newDate)
//                months.append(month)
//            }
//        }
//    }
//}

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
