//
//  EventType.swift
//  Calendar
//
//  Created by Nate Graham on 9/10/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import Foundation

enum GigType: Int {
    
    case Venue
    case OpeningSong
    case ClosingSong
    case EncoreSong
    
    var description: String {
        
        switch self {
            
        case .Venue:
            return "Venue"
        case .OpeningSong:
            return "Opening Song"
        case .ClosingSong:
            return "Closing Song"
        case .EncoreSong:
            return "Encore Song"
        }
    }
    
    var key: String {
        switch self {
        case .Venue:
            return "venue"
        case .OpeningSong:
            return "openingSong"
        case .ClosingSong:
            return "closingSong"
        case .EncoreSong:
            return "encoreSong"
        }
    }
}
