//
//  Month.swift
//  Calendar
//
//  Created by Nate Graham on 8/13/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import Foundation

struct Year {
    let year: Int
    var months = [Month]()
    
    
    init(date: Date) {
        let calendar = Calendar.autoupdatingCurrent
        
        self.year = calendar.component(.year, from: date)
        
        for i in 0 ..< 12 {
            if let newDate = calendar.date(byAdding: .month, value: i, to: date) {
                let month = Month(date: newDate)
                months.append(month)
            }
        }
    }
}
