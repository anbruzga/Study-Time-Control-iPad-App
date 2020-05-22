//
//  DetailViewController.swift
//  StudyTracker
//
//  Created by Antanas Bruzga on 20/05/2020.
//  Copyright © 2020 Antanas Bruzga. All rights reserved.
//

import UIKit
import CoreData

//@@@@@@@@@@@@@@@@@@
// Taken from user Frankie at https://stackoverflow.com/users/2047476/frankie
//https://stackoverflow.com/questions/31390466/swift-how-to-remove-a-decimal-from-a-float-if-the-decimal-is-equal-to-0
extension Float {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
//@@@@@@@@@@@@@@@@@

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate  {
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    let cellColour:UIColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.1)
    let cellSelColour:UIColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.2)
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
        configureView()
        
        // selecting first cell programatically
        
        //let index = NSIndexPath(row: 0, section: 0)
        //self.tableView.selectRow(at: index as IndexPath, animated: true, scrollPosition: UITableView.ScrollPosition.middle)
        
        
    }
    
    
    // MARK: - CONFIGURE the cell
    func configureCell (_ cell: UITableViewCell, indexPath: IndexPath){
        //get the cell that is passed to this function as custom cell
        let cell = cell as! CustomTableViewCell
        
        // 0. retrieve the fetched object
        let fetchedTask = self.fetchedResultsController.fetchedObjects?[indexPath.row]
        
        // 1. set title and notes
        cell.title.text = fetchedTask?.title
        cell.notes.text = fetchedTask?.notes
        
        //2. progress bar - get percentage, round it and clean floating point
        cell.progressBarPercentLeft.progress = fetchedTask?.progress ?? 0.0
        let percentCompleted = round((fetchedTask?.progress ?? 0.0) * 100);
        cell.percentCompleted.text = String(percentCompleted.clean) + " %"
        
        //3. count daysLeft and progressBar
        //3.1 set daysLeft label
        let dateNow = Date()
        let dateDue = fetchedTask?.taskDueDate
        let dateWhenSet = fetchedTask?.startDate
        let timeLeft: [Int] = absDayAndHourBetweenTwoDates(dateNow, dateDue!)
        let hoursLeft = timeLeft[1]%24
        let daysLeft = timeLeft[0]
        let timeLeftStr: String = " \(daysLeft)D, \(hoursLeft)Hrs"
        
        cell.daysLeft.text = timeLeftStr
        
        //3.2 set daysLeft progress bar
        // days left progress bar looks into  1 - (Ratio of DateNow and DateDue)
        let currentProgress = timeLeft[1]
        
        // This is displaying diff between date due and date now!!! TODO
        // MAX PROGRESS is 1 - (RATIO in hrs of dateWhenSet of assessment AND dueTime)
        let maxProgress: Int =  absHoursBetweenTwoDates(dateWhenSet!, dateDue!)
        let progressRatioReversed = Float(1 - (Float(currentProgress) / Float(maxProgress)))
        
        cell.progressBarDaysLeft.progress = progressRatioReversed
        
        
        
        // 4. Set cell indexes
        cell.cellNo.text = "Task " + String(indexPath.row+1)
        
        // 5. Set cell notes
        if let taskNotes =  self.fetchedResultsController.fetchedObjects?[indexPath.row].notes {
            cell.detailTextLabel?.text = taskNotes
        }
        else {
            cell.detailTextLabel?.text = ""
        }
        // 6. Set cell color
        cell.backgroundColor = cellColour
        
        
    }
    
    func numberOfSections( in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    
    func configureView() {
        // Update the user interface for the detail item.
        if let assessment = assessment {
            if let label = detailDescriptionLabel { // todo is this needed??
                label.text = assessment.moduleName
            }
        }
    }
    
    
    
    var assessment: Assessment? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    var task: Task?
    
    // MARK: - PREPARE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if let identifier = segue.identifier {
            switch identifier{
            case "assessmentSummary":
                let destVC = segue.destination as! AssessmentSummaryViewController
                destVC.currentAssessment = self.assessment
                break
            case "addTask":
                let object = self.assessment
                let controller = segue.destination as! AddTaskViewController
                controller.currentAssessment = object
                break
            case "editTask":
                if let indexPath = tableView.indexPathForSelectedRow {
                    // let context = fetchedResultsController.managedObjectContext
                    let object = fetchedResultsController.object(at: indexPath)
                    let assessment = self.assessment
                    let controller = segue.destination as! EditTaskViewController
                    controller.currentAssessment = assessment
                    controller.currentTask = object
                }
                break
            default:
                break
            }
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
        
        //configure the cell here
        self.configureCell(cell, indexPath: indexPath)
        let backgroundView = UIView()
        backgroundView.backgroundColor = cellSelColour
        cell.selectedBackgroundView = backgroundView
        return cell
    }
    
    
    
    
    // MARK: - Fetched results controller
    var _fetchedResultsController: NSFetchedResultsController<Task>? = nil
    var fetchedResultsController: NSFetchedResultsController<Task> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        let currentAssessment = self.assessment
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        // true for alphabetical sorting
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if (self.assessment != nil){
            let predicate = NSPredicate(format: "hasAssessment = %@", currentAssessment!)
            fetchRequest.predicate = predicate
        }
        else {
            // force programamtic seleciton to the first line? TODO
            let predicate = NSPredicate(format: "assessment = %@",  "Pink Floyd")
            fetchRequest.predicate = predicate
        }
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController<Task>(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: #keyPath(Task.assessment),
            cacheName: nil )
        
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    
    
    
    
    
    // MARK: - TABLE EDITING
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.configureCell(tableView.cellForRow(at: indexPath!)!, indexPath: newIndexPath!)
        case .move:
            self.configureCell(tableView.cellForRow(at: indexPath!)!, indexPath: newIndexPath!)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    
    
}

