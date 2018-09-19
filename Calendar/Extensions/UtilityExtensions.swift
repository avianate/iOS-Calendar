//
//  Utilities.swift
//  Calendar
//
//  Created by Nate Graham on 9/13/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import Foundation

extension Date {
    
    func toString() -> String {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "en_US")
        
        return formatter.string(from: self)
    }
}

extension String {
    func toDate() -> Date {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "en_US")
        
        return formatter.date(from: self)!
    }
}
