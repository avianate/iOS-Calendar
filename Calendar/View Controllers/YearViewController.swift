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
    var finishedInitialLayout = false
    var yearToDisplay = 1
    
    let transition = PopAnimator()
    
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
        
        self.navigationController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollToYear()
        
        let visibleYear = getVisibleYear()
        navigationItem.title = visibleYear != "" ? visibleYear : String(calendars[1].year)
    }
    
    override func viewDidLayoutSubviews() {
        
        if !finishedInitialLayout {
            scrollToYear()
            
            if calendarView.contentOffset.y > 0 {
                let visibleYear = getVisibleYear()
                navigationItem.title = visibleYear != "" ? visibleYear : String(calendars[1].year)
                finishedInitialLayout = true;
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
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
    
    private func getVisibleYear() -> String {
        let indexPath = calendarView.indexPathsForVisibleItems.first
        if let section = indexPath?.section {
            let year = calendars[section].year
            return String(year)
        }
        
        return ""
    }
    
    private func scrollToYear() {
        let section: CGFloat = CGFloat(yearToDisplay)
        let headerHeight: CGFloat = 35
        let headerHeightOffset: CGFloat = headerHeight * (section + 1)
        let pageSize = calendarView.bounds.size.height
        let offset = CGPoint(x: 0, y: (pageSize * section) + headerHeightOffset)
        calendarView.setContentOffset(offset, animated: false)
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
        // TODO: Transition to MonthViewController
//        performSegue(withIdentifier: "SelectMonthSegue", sender: self)
        
        // don't forget the add the identifier to the view controller in interface builder
        let monthViewController = storyboard!.instantiateViewController(withIdentifier: "MonthViewController") as! MonthViewController
        monthViewController.transitioningDelegate = self
        
        let indexPath = calendarView.indexPathsForSelectedItems?.first
        self.yearToDisplay = indexPath?.section ?? 1
        
        if let indexPath = indexPath {
            monthViewController.calendars = calendars
            monthViewController.selectedYear = indexPath.section
            monthViewController.selectedMonth = indexPath.item
            monthViewController.delegate = self
        }
        
        navigationController?.pushViewController(monthViewController, animated: true)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let indexPath = calendarView.indexPathsForSelectedItems?.first
//        self.yearToDisplay = indexPath?.section ?? 1
//
//        if segue.identifier == "SelectMonthSegue" {
//            let destinationVC = segue.destination as! MonthViewController
//            if let indexPath = indexPath {
//                destinationVC.calendars = calendars
//                destinationVC.selectedYear = indexPath.section
//                destinationVC.selectedMonth = indexPath.item
//                destinationVC.delegate = self
//
//            }
//        }
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentTitle = navigationItem.title
        let newTitle = getVisibleYear()
        
        if currentTitle != newTitle {
            navigationItem.title = newTitle
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

extension YearViewController: MonthViewDelegate {
    
    func backButtonDidChange(title: String) {
        let newBackButton = UIBarButtonItem()
        newBackButton.title = title
        self.navigationItem.backBarButtonItem = newBackButton
    }
    
    func yearToDisplay(_ year: Int) {
        yearToDisplay = year
    }
}

//extension YearViewController: UIViewControllerTransitioningDelegate {
//    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        // conver the transition context's coordinate space to the selected image coordinate space
//        // to: nil will convert the selected image to the coordinate space of the window
//
//        // transition.originFrame = selectedImage!.superview!.convert(selectedImage!.frame, to nil)
//        // selectedImage?.isHidden = true
//        transition.presenting = true
//        return transition
//    }
//
//    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        transition.presenting = false
//        return transition
//    }
//}

// MARK: - UIViewControllerTransitioningDelegate

extension YearViewController: UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        // only perform custom animation if fromVC.title or toVC.title is 'Details'
//        let useCustom = operation == .push && toVC.title == "Details" || operation == .pop && fromVC.title == "Details"

//        if !useCustom {
//            return nil
//        }

        if operation == .push {

            guard let selected = calendarView.indexPathsForSelectedItems?.first else { return nil }
            let cell = calendarView.cellForItem(at: selected) as! MonthCollectionViewCell

            transition.originFrame = cell.superview!.convert(cell.frame, to: nil)
            transition.presenting = true
            transition.selectedIndexPath = selected

            return transition
        }

        transition.presenting = false
        return transition
    }
}
