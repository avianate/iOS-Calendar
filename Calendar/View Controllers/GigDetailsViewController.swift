//
//  GigDetailsViewController.swift
//  Calendar
//
//  Created by Nate Graham on 9/11/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import UIKit
import CoreData

protocol GigDelegate: class {
    func createOrUpdateGig(type: GigType, data: AnyObject)
}

class GigDetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var gigType: GigType?
    var venues = [Venue]()
    var songs = [Song]()
    var selectedDate: Date?
    var delegate: GigDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadDataForGigType()
    }
    

    private func loadDataForGigType() {
        guard let gigType = gigType else { return }
        
        switch gigType {
        case .Venue:
            if let results = retrieve(entity: "Venue") {
                for item in results {
                    if let venue = item as? Venue {
                        venues.append(venue)
                    }
                }
            }
        default:
            if let results = retrieve(entity: "Song") {
                for item in results {
                    if let song = item as? Song {
                        songs.append(song)
                    }
                }
            }
        }
    }
    
    private func retrieve(entity: String) -> [NSManagedObject]? {
        
        // 1 get the managed context from the app delegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.reset()
        
        // 2 create fetch request for all "Person" entities
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        
        // you can add a predicate: fetchRequest.predicate = NSPredicate("predicate CONTAINS[c] %@", valueToSearchFor)
        
        // 3 execute fetch request
        do {
             return try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return nil
    }
}

extension GigDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell")!
        let item = getItemTextForCell(indexPath)
        
        cell.textLabel?.text = item
        
        return cell
    }
    
    private func getItemTextForCell(_ indexPath: IndexPath) -> String {
        if gigType == GigType.Venue {
            let venue = venues[indexPath.row]
            return "\(venue.name ?? ""), \(venue.city ?? "") \(venue.stateProvince ?? "") \(venue.country ?? "")"
        }
        
        let song = songs[indexPath.row]
        
        return song.title ?? ""
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gigType == GigType.Venue ? venues.count : songs.count
    }
}

extension GigDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let gigType = gigType else { return }
        
        // get item from songs or venues
        let item = gigType == GigType.Venue ? venues[indexPath.row] : songs[indexPath.row]
        
        // update gigType with item for selected date
        delegate?.createOrUpdateGig(type: gigType, data: item)
        
        navigationController?.popViewController(animated: true)
    }
}
