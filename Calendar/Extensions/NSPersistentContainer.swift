//
//  NSPersistentContainer.swift
//  Calendar
//
//  Created by Nate Graham on 9/4/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import Foundation
import CoreData

import CoreData

extension NSPersistentContainer {
    
    func saveContextIfNeeded() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
