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
        let venue1 = NSManagedObject(entity: venueEntity, insertInto: context) as! Venue
        let venue2 = NSManagedObject(entity: venueEntity, insertInto: context) as! Venue
        
        let songEntity = NSEntityDescription.entity(forEntityName: "Song", in: context)!
        let openingSong = NSManagedObject(entity: songEntity, insertInto: context) as! Song
        let closingSong = NSManagedObject(entity: songEntity, insertInto: context) as! Song
        let encoreSong = NSManagedObject(entity: songEntity, insertInto: context) as! Song
        
        let today = calendar.startOfDay(for: Date()) // eg. 2016-10-10 00:00:00
        
        if hasData(forToday: today) {
            return
        }
        
        openingSong.setValue("Opener", forKey: "title")
        openingSong.setValue("John Doe", forKey: "composer")
        openingSong.setValue("Rock", forKey: "genre")
        openingSong.setValue([today.toString()], forKey: "datesPlayed")
        
        closingSong.setValue("Closer", forKey: "title")
        closingSong.setValue("Jane Doe", forKey: "composer")
        closingSong.setValue("Classic Rock", forKey: "genre")
        closingSong.setValue([today.toString()], forKey: "datesPlayed")
        
        encoreSong.setValue("Encore", forKey: "title")
        encoreSong.setValue("John / Jane Doe", forKey: "composer")
        encoreSong.setValue("Pop", forKey: "genre")
        encoreSong.setValue([today.toString()], forKey: "datesPlayed")
        
        venue1.setValue("Rose Bowl", forKey: "name")
        venue1.setValue("Pasadena", forKey: "city")
        venue1.setValue("CA", forKey: "stateProvince")
        venue1.setValue("USA", forKey: "country")
        venue1.setValue([today.toString()], forKey: "datesPlayed")
        
        venue2.setValue("Red Rock Amphitheater", forKey: "name")
        venue2.setValue("Morrison", forKey: "city")
        venue2.setValue("CO", forKey: "stateProvince")
        venue2.setValue("USA", forKey: "country")
        
        gig.setValue(openingSong, forKey: "openingSong")
        gig.setValue(closingSong, forKey: "closingSong")
        gig.setValue(encoreSong, forKey: "encoreSong")
        gig.setValue(venue1, forKey: "venue")
        gig.setValue(today.toString(), forKey: "date")
        
        do {
            try context.save()
            
        } catch let error as NSError {
            
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    private func hasData(forToday today: Date) -> Bool {
        let month = Month(date: today, forYear: calendar.component(.year, from: today))
        
        let result = month.getData(forDate: today)
        
        return result != nil
    }
    
    func removeOutdatedData() {
        // TODO: remove all old data
        // get all gigs with datesPlayed more than 1 year ago and delete them
    }
    
}
