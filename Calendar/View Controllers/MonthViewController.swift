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
    func yearToDisplay(_ year: Int)
}

// MARK: - VIEW CONTROLLER

class MonthViewController: UIViewController {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var calendarView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - PROPERTIES
    
    var calendars = [Calendar]()
    var months = [Month]()
    var numberOfYearsToShow = 3
    var selectedYear: Int?
    var selectedMonth: Int?
    var selectedDate: Date?
    var previouslySelectedCellIndex: IndexPath?
    var meetingForDate: Gig?
    
    var cellWidth: CGFloat = 40
    var marginWidth: CGFloat = 30
    var finishedInitialLayout = false;
    // tableViewData: dataType
    
    // MARK: - DELEGATES
    weak var delegate: MonthViewDelegate?
    
    // MARK: - VIEW LIFECYCEL METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        // get the year view to go back to
        let year = getVisibleYear()
        delegate?.yearToDisplay(year)
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
        let offset = getOffsetDays(forMonth: month)
        
        cell.dateLabel.text = getCellDayNumber(forMonth: month, withIndexPath: indexPath)
        setTextColorAndSelection(forCell: cell, withMonth: month, day: item, offset: offset, andIndex: indexPath)
        
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
        
        // set the cell accessory to show it as selected
        setTextColorAndSelection(forCell: selectedCell, withMonth: month, day: dayNumber, andIndex: indexPath, isSelected: true)
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
            
            print(tableView.indexPathForSelectedRow)
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let type = GigType(rawValue: indexPath.section)
                destinationVC.gigType = type
            }
        }
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
        return 5
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
        if let meeting = meetingForDate {
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
