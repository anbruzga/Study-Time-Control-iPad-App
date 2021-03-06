//
//  MasterViewController.swift
//  StudyTracker
//
//  Created by Antanas Bruzga on 20/05/2020.
//  Copyright © 2020 Antanas Bruzga. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    

    
    let cellColour:UIColor = UIColor(red: 1.0, green: 147.0/255.0, blue: 0.0, alpha: 0.1)
    let cellSelColour:UIColor = UIColor(red: 1.0, green: 157.0/255.0, blue: 0.0, alpha: 0.5)
    
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var currentAssessment: Assessment?

    @IBOutlet weak var editAssessmentButton: UIBarButtonItem!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
       // tableView.dataSource = self
        print("CREATED")
        
        // Restoring UI State:
        if (UserDefaults.standard.integer(forKey: "doRetrieveMasterCell") == 1) {
            let indexPathRestored = NSIndexPath(row: UserDefaults.standard.integer(forKey: "lastSelectedMasterCell"), section: 0)
            // selecting first cell programatically
            // let index = NSIndexPath(row: 0, section: 0)
            self.tableView.selectRow(at: indexPathRestored as IndexPath, animated: true, scrollPosition: UITableView.ScrollPosition.middle)
            tableView.delegate?.tableView!(tableView!, didSelectRowAt: indexPathRestored as IndexPath)
            let cell = tableView.cellForRow(at: indexPathRestored as IndexPath)
            performSegue(withIdentifier: "showDetail", sender: cell)
            
            if (UserDefaults.standard.integer(forKey: "editAssessmentPopoverActive") == 1) {
                performSegue(withIdentifier: "editAssessment", sender: cell)
                
            }
            
            else if (UserDefaults.standard.integer(forKey: "addAssessmentPopoverActive") == 1) {
                performSegue(withIdentifier: "addAssessment", sender: cell)
            }
        }
        
   
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    
    @objc
    func insertNewObject(_ sender: Any) {
        let context = self.fetchedResultsController.managedObjectContext
        // let newAssessment = Assessment(context: context)
        
        // If appropriate, configure the new managed object.
        // newAssessment.timestamp = Date()
        // newAssessment.moduleName = "test1ModuleName"
        
        // Save the context.
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
          if let indexPath = tableView.indexPathForSelectedRow {
              let object = fetchedResultsController.object(at: indexPath)
              currentAssessment = object
              let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
              controller.assessment = object
              controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
              controller.navigationItem.leftItemsSupplementBackButton = true
              detailViewController = controller
           // if let Task = controller.selectedTask {
          //      controller.s
          //  }
            
             
          }
        }
        if segue.identifier == "editAssessment"{
            let destVC = segue.destination as! EditAssessmentViewController
            destVC.currentAssessment = self.currentAssessment
        }
    }

    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let assessment = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withAssessment: assessment)

        let backgroundView = UIView()
        backgroundView.backgroundColor = cellSelColour
        cell.selectedBackgroundView = backgroundView
      
        cell.restorationIdentifier = "Assessment " + String(indexPath.row+1) //todo to save

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected cell number: \(indexPath.row)!")
        editAssessmentButton.isEnabled = true
        //DISABLE EDITTASK BUTTON NOTIF
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disableEditTaskDueLostFocus"), object: nil)
        UserDefaults.standard.set(indexPath.row, forKey: "lastSelectedMasterCell")
        UserDefaults.standard.set(1, forKey: "doRetrieveMasterCell")
        
    }
    
    override func tableView(_ tableView: UITableView,
                            didDeselectRowAt indexPath: IndexPath) {
        editAssessmentButton.isEnabled = false
        UserDefaults.standard.set(0, forKey: "doRetrieveMasterCell")
    }
    
   
    // MARK: - Configure Cell
    func configureCell(_ cell: UITableViewCell, withAssessment assessment: Assessment) {
        cell.textLabel!.text = assessment.moduleName
        cell.backgroundColor = cellColour
        
        
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<Assessment> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Assessment> = Assessment.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "dateWhenSet", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
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
    var _fetchedResultsController: NSFetchedResultsController<Assessment>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
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
            editAssessmentButton.isEnabled = false
            detailViewController?.addTaskButton.isEnabled = false
            currentAssessment = nil
           UserDefaults.standard.set(0, forKey: "doRetrieveMasterCell")
            
           NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadNilAssessmentSummary"), object: nil)
           break
        case .update:
            configureCell(tableView.cellForRow(at: indexPath!)!, withAssessment: anObject as! Assessment)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadAssessmentSummary"), object: currentAssessment)
            break;
        case .move:
            configureCell(tableView.cellForRow(at: indexPath!)!, withAssessment: anObject as! Assessment)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
            break;
        default:
            return
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
     // In the simplest, most efficient, case, reload the table view.
     tableView.reloadData()
     }
     */
    
}

