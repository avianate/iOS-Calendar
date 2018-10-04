//
//  CalendarViewController.swift
//  Calendar
//
//  Created by Nate Graham on 8/13/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import UIKit
import CoreData

// MARK: - PROTOCOLS

protocol MonthViewDelegate: class {
    func backButtonDidChange(title: String)
//    optional func yearToDisplay(_ year: Int)
    func update(year: Int, month: Int)
}

// MARK: - VIEW CONTROLLER

class MonthViewController: UIViewController, GigDelegate {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var calendarView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    // MARK: - PROPERTIES
    
    var calendars = [Calendar]()
    var months = [Month]()
    var numberOfYearsToShow = 3
    var selectedYear: Int?
    var selectedMonth: Int?
    var selectedDate: Date?
    var previouslySelectedCellIndex: IndexPath?
    var gigForDate: Gig?
    
    var cellWidth: CGFloat = 40
    var marginWidth: CGFloat = 30
    var finishedInitialLayout = false;
    // tableViewData: dataType
    
    // MARK: - DELEGATES
    weak var delegate: MonthViewDelegate?
    
    // MARK: - VIEW LIFECYCEL METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        calendarHeightConstraint.constant = view.frame.height / 2
        
        if let selectedMonth = selectedMonth, let selectedYear = selectedYear, months.count > 0 {
            let monthIndex = (selectedYear * 12) + selectedMonth
            let month = months[monthIndex]
            let buttonTitle = "\(month.name)"
            delegate?.backButtonDidChange(title: buttonTitle)
        }
        
        self.dismiss(animated: true, completion: nil)
        
        // Layout cells
        let frameWidth = view.frame.size.width
        let width = (frameWidth - (cellWidth * 7) - marginWidth) / 7
        let layout = calendarView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = width
        layout.sectionHeadersPinToVisibleBounds = false
        
        if calendars.count > 0 {
            for calendar in calendars.enumerated() {
                months.append(contentsOf: calendar.element.months)
            }
        }
        
        tableView.estimatedSectionHeaderHeight = 100.0
        tableView.estimatedRowHeight = 75.0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let indexPath = calendarView.indexPathsForSelectedItems?.first else { return }
        
        let cell = calendarView.cellForItem(at: indexPath) as! DateCollectionViewCell
        let day = getDay(fromCell: cell)
        loadMeetingDataForDate(fromSection: indexPath.section, andDay: day)
        
        updateCalendarViewCell()
        
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // get the year view to go back to
        let year = getVisibleYear()
        let month = getVisibleMonth()
//        delegate?.yearToDisplay(year)
        delegate?.update(year: year, month: month)
    }
    
    override func viewDidLayoutSubviews() {
        // if this is the first time month view is loaded
        // set the scroll offset to the month that was tapped
        if !finishedInitialLayout {
            
            if selectedYear != nil && selectedMonth != nil {
                
                setScrollOffset()
                
                if calendarView.contentOffset.y > 0 {
                    finishedInitialLayout = true;
                }
            }
        }
    }
    
    func createOrUpdateGig(type: GigType, data: AnyObject) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.persistentContainer.viewContext
        //        context.reset()
        
        // check if gig already exists
        if let indexPath = calendarView.indexPathsForSelectedItems?.first, let date = selectedDate {
            let month = months[indexPath.section]
            let dateString = date.toString()
            
            if let existingGig = month.getData(forDate: date) {
                existingGig.setValue(data, forKey: type.key)
                
                if type == GigType.Venue {
                    existingGig.setValue(dateString, forKey: "date")
                } else {
                    update(datePlayed: date, forGigType: type, andGig: existingGig, withContext: context)
                }
                
                do {
                    try context.save()
                } catch {
                    let error = error as NSError
                    print("Couldn't update gig: \(error) \(error.userInfo)")
                }
                
                return
            }
        }
        
        // create new gig
        let gigEntity = NSEntityDescription.entity(forEntityName: "Gig", in: context)!
        let newGig = NSManagedObject(entity: gigEntity, insertInto: context) as! Gig
        
        // add data to gigType property of gig
        data.setValue([selectedDate?.toString()], forKey: "datesPlayed")
        newGig.setValue(data, forKey: type.key)
        
        // set selectedDate to gigType datePlayed property
        newGig.setValue(selectedDate!.toString(), forKey: "date")
        // save the context
        
        do {
            try context.save()
            
        } catch {
            let error = error as NSError
            print("Couldn't save gig: \(error) \(error.userInfo)")
        }
    }
    
    private func update(datePlayed date: Date, forGigType type: GigType, andGig gig: Gig, withContext context: NSManagedObjectContext) {
        
        var song: Song?
        
        switch type {
        case .ClosingSong:
            song = gig.closingSong
        case .EncoreSong:
            song = gig.encoreSong
        case .OpeningSong:
            song = gig.openingSong
        case .Venue:
            break
        }
        
        if var datesPlayed = song?.datesPlayed {
            
            datesPlayed.append(date.toString())
            
            let temp = Set(datesPlayed)
            datesPlayed = Array(temp)
            
            song?.setValue(datesPlayed, forKey: "datesPlayed")
        }
        
        do {
            try context.save()
        } catch {
            let error = error as NSError
            print("Couldn't update gig: \(error) \(error.userInfo)")
        }
    }
    
    private func remove(type: GigType, fromGig gig: Gig) {
        guard let dateString = selectedDate?.toString() else { return }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        var datesPlayed = [String]()
        var newDatesPlayed = [String]()
        let isVenue = type == GigType.Venue
        
        if isVenue {
            if let venue = gig.venue, let played = venue.datesPlayed {
                datesPlayed = played
                newDatesPlayed = datesPlayed.filter {$0 != dateString}
                venue.setValue(newDatesPlayed, forKey: "datesPlayed")
                gig.setValue(nil, forKey: "venue")
            }
        } else if !isVenue, let song = gig.value(forKey: type.key) as? Song, let played = song.datesPlayed  {
            datesPlayed = played
            newDatesPlayed = datesPlayed.filter {$0 != dateString }
            song.setValue(newDatesPlayed, forKey: "datesPlayed")
            gig.setValue(nil, forKey: type.key)
        }
        
        if gigIsEmpty(gig) {
            context.delete(gig)
        }
        
        do {
            try context.save()
        } catch {
            let error = error as NSError
            print("Can't remove datePlayed: \(error) \(error.userInfo)")
        }
    }
    
    private func gigIsEmpty(_ gig: Gig) -> Bool {
        return gig.venue == nil && gig.openingSong == nil && gig.closingSong == nil && gig.encoreSong == nil
    }
    
    private func updateCalendarViewCell() {
        guard let indexPath = calendarView.indexPathsForSelectedItems?.first else { return }
        guard let cell = calendarView.cellForItem(at: indexPath) as? DateCollectionViewCell else { return }
        guard let date = selectedDate else { return }
        
        setGigAccessory(forCell: cell, ofDate: date)
    }
}

// MARK: - COLLECTION VIEW

extension MonthViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = calendarView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeader
        
        let section = Section()
        section.name = titleForSectionAt(indexPath: indexPath)
        
        let isCurrentMonth = months[indexPath.section].isCurrentMonth
        
        view.isActive = isCurrentMonth
        view.section = section
        
        return view
    }
    
    func titleForSectionAt(indexPath: IndexPath) -> String {
        let month = months[indexPath.section]
        
        return month.name
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateMonthLabel()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return months.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = calendarView.dequeueReusableCell(withReuseIdentifier: "CalendarDayCell", for: indexPath) as! DateCollectionViewCell
        
        let item = indexPath.item
        let section = indexPath.section
        
        let month = months[section]
        let year = getYear(forSection: section)
        let offset = getOffsetDays(forMonth: month)
        let day = item - offset
        
        cell.dateLabel.text = getCellDayNumber(forMonth: month, withIndexPath: indexPath)
        setTextColorAndSelection(forCell: cell, withMonth: month, day: item, offset: offset, andIndex: indexPath)
        
        let dateComponents = DateComponents(year: year, month: month.month, day: day)

        if day > 0, let date = month.getDateFrom(components: dateComponents) {
            setGigAccessory(forCell: cell, ofDate: date)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedCell = collectionView.cellForItem(at: indexPath) as! DateCollectionViewCell
        let day = selectedCell.dateLabel.text
        
        if day == nil || day == "" {
            return
        }
        
        let month = months[indexPath.section]
        let dayNumber = getDay(fromCell: selectedCell)
        
        let calendarMonth = getMonthInYear(fromSection: indexPath.section)
        let year = getYear(forSection: indexPath.section)
        let dateComponents = DateComponents(year: year, month: calendarMonth, day: dayNumber)
        selectedDate = month.getDateFrom(components: dateComponents)
        
        // set the cell accessory to show it as selected
        setTextColorAndSelection(forCell: selectedCell, withMonth: month, day: dayNumber, andIndex: indexPath, isSelected: true)
        
        if let date = month.getDateFrom(components: dateComponents) {
            setGigAccessory(forCell: selectedCell, ofDate: date)
        }
        
        previouslySelectedCellIndex = indexPath
        
        // fetches meeting data for selected day and updates the tableView
        loadMeetingDataForDate(fromSection: indexPath.section, andDay: dayNumber)
    }
}

// MARK: - TABLE VIEW DELEGATE

extension MonthViewController: UITableViewDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailSegue" {
            let destinationVC = segue.destination as! GigDetailsViewController
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let type = GigType(rawValue: indexPath.section)
                destinationVC.gigType = type
                destinationVC.delegate = self
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        let deleteHandler: UIContextualAction.Handler = { [weak self] action, view, callback in
            
            
            // if cell is empty, return
            if cell?.textLabel?.text == "", cell == nil {
                return
            }
            
            // get gigType
            if let gig = self?.gigForDate, let gigType = GigType(rawValue: indexPath.section) {
                
                self?.remove(type: gigType, fromGig: gig)
                UIView.animate(withDuration: 0.5, animations: {
                    cell?.alpha = 0
                    cell?.textLabel?.text = ""
                }, completion: nil)
                // remove item from gig
                // remove date for gigType item
                // deleteRow in table view or just remove text in cell
            }

//            self?.contacts.remove(at: indexPath.row)
//
            
            
            self?.updateCalendarViewCell()
            
            callback(true)
        }
        
        let deleteAction = UIContextualAction(style: .normal, title: "Delete", handler: deleteHandler)
        deleteAction.backgroundColor = UIColor.red
        let actions = [deleteAction]
        let config = UISwipeActionsConfiguration(actions: actions)
        
        return config
    }
}

// MARK: - TABLE VIEW DATA SOURCE

extension MonthViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let type = GigType(rawValue: section)
        return type?.description
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        let section = indexPath.section
        // get the selected date
        if let meeting = gigForDate {
            // get Gigs for selected date
            let numberAndTitle = getSongTitle(forSection: section, forMeeting: meeting)
            cell?.textLabel?.text = numberAndTitle
            // display Gig for selected date and section
        } else {
            cell?.textLabel?.text = ""
        }
        
        return cell!
    }
    
    private func getSongTitle(forSection section: Int, forMeeting meeting: Gig) -> String {
        
        let type = GigType(rawValue: section)
        var song: Song?
        
        if let type = type {
            switch type {
            case .OpeningSong:
                song = meeting.openingSong
            case .ClosingSong:
                song = meeting.closingSong
            case .Venue:
                guard let venue = meeting.venue else { return "" }
                return "\(venue.name ?? ""): \(venue.city ?? ""), \(venue.stateProvince ?? "") \(venue.country ?? "")"
            default:
                song = meeting.encoreSong
            }
        }
        
        return song?.title ?? ""
    }
}
