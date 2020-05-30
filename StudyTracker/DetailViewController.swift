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
    @IBOutlet weak var editTaskButton: UIBarButtonItem!
    @IBOutlet weak var addTaskButton: UIBarButtonItem!
    
    
    let cellColour:UIColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.1)
    let cellSelColour:UIColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.2)
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
        configureView()
        
        // disables editTask button if no tasks are present
        //if (numberOfSections(in: tableView) > 0){
        //    editTaskButton.isEnabled = true
        //}
        
        // disables addTaskButton if no assesment is selected
        if assessment == nil {
            editTaskButton.isEnabled = false
            addTaskButton.isEnabled = false
        }
        else {
            addTaskButton.isEnabled = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(disableEditTaskDueLostFocus), name: NSNotification.Name(rawValue: "disableEditTaskDueLostFocus"), object: nil)
        
        //Reset the avgProgress on reloading view
        AvgProgress.reset()
        
    }
    @objc func disableEditTaskDueLostFocus(){
        editTaskButton.isEnabled = false
    }
    override func viewDidDisappear(_ animated: Bool) {
        editTaskButton.isEnabled = false
        addTaskButton.isEnabled = false
    }
    
    @objc func animateProgress(){
        let cP = self.view.viewWithTag(101) as! CircularProgressView
        cP.setProgressWithAnimation(duration: 1.0, value: 0.7)
        
    }
    
    // MARK: - CONFIGURE the cell
    func configureCell (_ cell: UITableViewCell, indexPath: IndexPath){
        // 0. get the cell that is passed to this function as custom cell
        let cell = cell as! CustomTableViewCell
        
        // 0.1 retrieve the fetched object
        let fetchedTask = self.fetchedResultsController.fetchedObjects?[indexPath.row]
        
        // 1. set title and notes
        cell.title.text = fetchedTask?.title
        cell.notes.text = fetchedTask?.notes
        
        //2. progress bar percentage - get percentage, round it and clean floating point
        cell.progressBarPercentLeft.progress = fetchedTask?.progress ?? 0.0
        cell.progressBarPercentLeft.trackColour = UIColor(red: 255/255, green: 255/255, blue: 102/255, alpha: 0.75)
        cell.progressBarPercentLeft.progressColour = UIColor(red: 255/255, green: 69/255, blue: 147/255, alpha: 0.75)
        
        cell.progressBarPercentLeft.tag = 101
        cell.progressBarPercentLeft.setProgressWithAnimation(duration: 1.0, value: fetchedTask?.progress ?? 0.0)
        
        
        let percentCompleted = round((fetchedTask?.progress ?? 0.0) * 100);
        cell.percentCompleted.text = String(percentCompleted.clean) + " %"
        
        //3. count daysLeft and progressBar
        //3.1 set daysLeft label
        let dateNow = Date()
        let dateDue = fetchedTask?.taskDueDate
        let dateWhenSet = fetchedTask?.startDate
        
        var timeLeftStr: String
        if (dateNow > dateDue!){
            timeLeftStr = "Past Deadline"
        }
        else {
            let seconds: Int = absSecondsBetweenTwoDates(dateNow, dateDue!)
            timeLeftStr = describeMinutes(minutes: seconds/60)
        }
        cell.daysLeft.text = timeLeftStr
        
        //3.2 set daysLeft progress bar
        let currentProgress: Int = absSecondsBetweenTwoDates(dateNow, dateWhenSet!)
        let maxProgress: Int = absSecondsBetweenTwoDates(dateWhenSet!, dateDue!)
        
        if(maxProgress != 0){ // to avoid division by 0 at all costs
            // must use float/double arithmetic!!
            let progressRatio: Float = Float(Float(currentProgress)/Float(maxProgress))
            cell.progressBarDaysLeft.progress = CGFloat(progressRatio)
            

            print("CELLS CURRENT PROGRESS \(currentProgress)")
            print("MAX PROGRESS \(maxProgress)")
            print("PROGRESS RATIO \(progressRatio)")
        }
        else{ // can happen if user sets the task at default DateTime
            print("CELLS MAX PROGRESS IS 0")
            print("DATE WHEN SET: \(String(describing: dateWhenSet?.description))")
            print("DATE DUE: \(String(describing: dateDue?.description))")
        }
        
        
        
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
        
        // 7. count avg
        AvgProgress.add(cell.progressBarPercentLeft.progress)
        let rowsNum = self.tableView.numberOfRows(inSection: 0)
        if (AvgProgress.getMembers() == rowsNum){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPercentCompletedProgressBar"), object: nil)
        }
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
            // force programamtic seleciton to the first line?
            // Instead, impossible predicate given, hack..
            let predicate = NSPredicate(format: "assessment = %@",  "")
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
        notifyAboutProgressUpdate()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            
            
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            editTaskButton.isEnabled = false
        default:
            return
        }
    }
    
    //Change summary when new task is inserted - progress bars
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            editTaskButton.isEnabled = false
        case .update:
            self.configureCell(tableView.cellForRow(at: indexPath!)!, indexPath: newIndexPath!)
            //editTaskButton.isEnabled = false
        case .move:
            self.configureCell(tableView.cellForRow(at: indexPath!)!, indexPath: newIndexPath!)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
            
        default:
            return
        }
        
    }
    
    func notifyAboutProgressUpdate(){
        if (self.tableView.numberOfSections < 1){
            AvgProgress.reset()
        }
        else{
            // @@@@@@@@@@@@@@@@@@@@@@@@
            // REFERENCE FROM: https://stackoverflow.com/questions/30281451/iterate-over-all-the-uitablecells-given-a-section-id
            // User Steve at https://stackoverflow.com/users/5553768/steve
            
            AvgProgress.reset()
            for section in 0...self.tableView.numberOfSections - 1 {
                for row in 0...self.tableView.numberOfRows(inSection: section) - 1 {
                    let cell: CustomTableViewCell = self.tableView.cellForRow(at: NSIndexPath(row: row, section: section) as IndexPath) as! CustomTableViewCell
                    
                    //print("Section: \(section)  Row: \(row)")
                // @@@@@@@@@@@@@@@@@@@@@@@@
                    AvgProgress.add(cell.progressBarPercentLeft.progress)
                }
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPercentCompletedProgressBar"), object: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            editTaskButton.isEnabled = false
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
    
    
    // Disabling and enabling buttons according to what cell is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected cell number: \(indexPath.row) ")
        editTaskButton.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView,
                   didDeselectRowAt indexPath: IndexPath) {
        editTaskButton.isEnabled = false
    }

    
}

