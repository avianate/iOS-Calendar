//
//  YearViewController.swift
//  Calendar
//
//  Created by Nate Graham on 8/13/18.
//  Copyright © 2018 Nate Graham. All rights reserved.
//

import UIKit

class YearViewController: UIViewController {
    
    @IBOutlet weak var calendarView: UICollectionView!
    
    var columns: CGFloat {
        return UIDevice.current.orientation.isLandscape ? CGFloat(4) : CGFloat(3)
    }
    
    var rows: CGFloat {
        return UIDevice.current.orientation.isLandscape ? CGFloat(3) : CGFloat(4)
    }
    
    var cellSpacing: CGFloat = 10
    var interItemSpacing: CGFloat = 0
    var lineSpacing: CGFloat = 5
    
    let minimumHeight: CGFloat = 144.5
    
    var calendars = [Calendar]()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        calendarView.showsVerticalScrollIndicator = false
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let date1 = dateFormatter.date(from: "2017/01/01")
        let date2 = dateFormatter.date(from: "2018/01/01")
        let date3 = dateFormatter.date(from: "2019/01/01")
        
        calendars.append(Calendar(date: date1!))
        calendars.append(Calendar(date: date2!))
        calendars.append(Calendar(date: date3!))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        calendarView.scrollToItem(at: IndexPath(item: 0, section: 1), at: .top, animated: false)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // invalidate the year collection view inside the coordinator animate function
        // then inside the animation completion handler, we invalidate each month cell's colleciton view
        coordinator.animate(alongsideTransition: { (context) in
            
            self.calendarView.collectionViewLayout.invalidateLayout()
            
        }) { (context) in
            
            let cells = self.calendarView.visibleCells

            for cell in cells {
                guard let cell = cell as? MonthCollectionViewCell else { continue }
                cell.invalidateLayout()
                cell.collectionView.reloadData()
            }
        }
    }
}

extension YearViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = calendarView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "YearHeader", for: indexPath) as! SectionHeader
        
        let section = Section()
        section.name = titleForSectionAt(indexPath: indexPath)
        
        view.section = section
        view.isActive = calendars[indexPath.section].isCurrentYear
        
        return view
    }
    
    func titleForSectionAt(indexPath: IndexPath) -> String {
        return String(calendars[indexPath.section].year)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendars[section].months.count
    }
    
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return calendars.count
        }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = calendarView.dequeueReusableCell(withReuseIdentifier: "MonthCell", for: indexPath) as! MonthCollectionViewCell
        let item = indexPath.item
        let section = indexPath.section
        
        let month = calendars[section].months[item]
        cell.month = month
        cell.update()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected cell: \(calendars[indexPath.section].months[indexPath.item].name)");
        // TODO: Transition to MonthViewController
        performSegue(withIdentifier: "SelectMonthSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = calendarView.indexPathsForSelectedItems?.first
        
        if segue.identifier == "SelectMonthSegue" {
            let destinationVC = segue.destination as! MonthViewController
            if let indexPath = indexPath {
                destinationVC.calendars = calendars
                destinationVC.selectedYear = indexPath.section
                destinationVC.selectedMonth = indexPath.item
            }
        }
    }
}

extension YearViewController: UICollectionViewDelegateFlowLayout {
    
    func getCellWidth() -> CGFloat {
        
        let frameWidth = calendarView.frame.size.width
        let cellWidth = (frameWidth - (cellSpacing * (columns - 1))) / columns
        
        return cellWidth
    }
    
    func getCellHeight() -> CGFloat {
        
        let frameHeight = calendarView.frame.size.height
        var cellHeight = (frameHeight - (lineSpacing * (rows - 1))) / rows
        
        cellHeight = cellHeight < minimumHeight ? minimumHeight : cellHeight
        
        return cellHeight
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemSize = CGSize(width: getCellWidth(), height: getCellHeight())
        
        return itemSize
    }
}
