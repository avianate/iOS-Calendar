//
//  Seeder.swift
//  LDSChorister
//
//  Created by Nate Graham on 9/5/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Seeder {
    
    private let calendar = UIKit.Calendar.autoupdatingCurrent
    private var context: NSManagedObjectContext!
    
    func seedDB(withContext context: NSManagedObjectContext) {
        
        self.context = context
        
        let gigEntity = NSEntityDescription.entity(forEntityName: "Gig", in: context)!
        let gig = NSManagedObject(entity: gigEntity, insertInto: context) as! Gig
        
        let venueEntity = NSEntityDescription.entity(forEntityName: "Venue", in: context)!
        let venue = NSManagedObject(entity: venueEntity, insertInto: context) as! Venue
        
        let songEntity = NSEntityDescription.entity(forEntityName: "Song", in: context)!
        let openingSong = NSManagedObject(entity: songEntity, insertInto: context) as! Song
        let closingSong = NSManagedObject(entity: songEntity, insertInto: context) as! Song
        let encoreSong = NSManagedObject(entity: songEntity, insertInto: context) as! Song
        
        let today = calendar.startOfDay(for: Date()) as NSDate // eg. 2016-10-10 00:00:00
        
        if hasData(forToday: today) {
            return
        }
        
        openingSong.setValue("Opener", forKey: "title")
        openingSong.setValue("John Doe", forKey: "composer")
        openingSong.setValue("Rock", forKey: "genre")
        openingSong.setValue([today], forKey: "datesPlayed")
        
        closingSong.setValue("Closer", forKey: "title")
        closingSong.setValue("Jane Doe", forKey: "composer")
        closingSong.setValue("Classic Rock", forKey: "genre")
        closingSong.setValue([today], forKey: "datesPlayed")
        
        encoreSong.setValue("Encore", forKey: "title")
        encoreSong.setValue("John / Jane Doe", forKey: "composer")
        encoreSong.setValue("Pop", forKey: "genre")
        encoreSong.setValue([today], forKey: "datesPlayed")
        
        venue.setValue("Rose Bowl", forKey: "name")
        venue.setValue("Pasadena", forKey: "city")
        venue.setValue("CA", forKey: "stateProvince")
        venue.setValue("USA", forKey: "country")
        venue.setValue([today], forKey: "datesPlayed")
        
        gig.setValue(openingSong, forKey: "openingSong")
        gig.setValue(closingSong, forKey: "closingSong")
        gig.setValue(encoreSong, forKey: "encoreSong")
        gig.setValue(venue, forKey: "venue")
        gig.setValue(today, forKey: "date")
        
        do {
            try context.save()
            
        } catch let error as NSError {
            
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    private func hasData(forToday today: NSDate) -> Bool {
        let today = today as Date
        let month = Month(date: today, forYear: calendar.component(.year, from: today))
        
        let result = month.getData(forDate: today)
        
        return result != nil
    }
    
}
