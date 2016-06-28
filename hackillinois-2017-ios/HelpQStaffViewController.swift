//
//  HelpQStaffViewController.swift
//  hackillinois-2017-ios
//
//  Created by Shotaro Ikeda on 6/14/16.
//  Copyright © 2016 Shotaro Ikeda. All rights reserved.
//

import UIKit
import CoreData

class HelpQStaffViewController: GenericCardViewController, NSFetchedResultsControllerDelegate, UICollectionViewDataSource {

    @IBOutlet weak var helpQCollection: UICollectionView!
    
    /* User Information */
    var user: User = (Helpers.loadContext(entityName: "User", fetchConfiguration: nil) as! [User])[0]
    
    /* Core Data components */
    var fetchedResultsController: NSFetchedResultsController!
    var fetchPredicate: NSPredicate!
    
    /* Core Data functions */
    func loadSavedData() {
        if fetchedResultsController == nil {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let fetch = NSFetchRequest(entityName: "HelpQ")
            let languageSort = NSSortDescriptor(key: "language", ascending: false)
            let inChargeSort = NSSortDescriptor(key: "isHelping", ascending: false)
            let modifiedSort = NSSortDescriptor(key: "modified", ascending: false)
            fetch.sortDescriptors = [inChargeSort, languageSort, modifiedSort]
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: appDelegate.managedObjectContext, sectionNameKeyPath: "language", cacheName: nil)
        }
        
        fetchedResultsController.fetchRequest.predicate = fetchPredicate
        
        do {
            try self.fetchedResultsController.performFetch()
            self.helpQCollection.reloadData()
        } catch {
            print("Error loading: \(error)")
        }
    }
    
    func populateSampleData() {
        print("Creating Dummy Data")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let createHelpQLambda: (String, String, String, String) -> HelpQ = { (tech, lang, loc, desc) in
            let helpQ = NSEntityDescription.insertNewObjectForEntityForName("HelpQ", inManagedObjectContext: appDelegate.managedObjectContext) as! HelpQ
            helpQ.initialize(tech, language: lang, location: loc, description: desc)
            return helpQ
        }
        
        createHelpQLambda("Node JS", "Javascript", "Siebel 2202", "Help with Asynchronous Calls")
        createHelpQLambda("Memory Allocation/Deallocation", "C++", "Siebel 1404","Help with unknown use after free error")
        createHelpQLambda("Threading", "C", "ECEB 2201","Cannot figure out how to multithread my code.")
        createHelpQLambda("Python", "Python", "Siebel", "How to print with python")
        createHelpQLambda("UITableView", "iOS", "Find me around ECEB labs", "Automatic Dimension is creates strange behavior for animations")
        createHelpQLambda("Machine Learning", "Python", "Labs at Siebel", "Which model to use?")
        createHelpQLambda("MySQL", "Python-Flask", "around 2nd floor DCL", "How do I connect Python to my database?")
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [unowned self] in
            Helpers.saveContextMainThread()
            dispatch_async(dispatch_get_main_queue()) {
                self.helpQCollection.reloadData()
            }
        }
    }
    
    // Mark: UIViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fetchPredicate = nil
        loadSavedData()
        
        // Set delegates
        fetchedResultsController.delegate = self
        helpQCollection.dataSource = self
        helpQCollection.delegate = self
        
        /* Remove for production */
        if fetchedResultsController.fetchedObjects?.count == 0 {
            populateSampleData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Mark: Button Handler
    func cellButtonPressed(sender: ReferencedButton) {
        let helpQItem = sender.referenceObject as! HelpQ
        helpQItem.assignMentor(mentor: user.name, helpStatus: true)
        helpQItem.isHelping = NSNumber(bool: !helpQItem.isHelping.boolValue)
        
        /* Configure button */
        if helpQItem.isHelping.boolValue {
            sender.setTitle("Stop Helping User", forState: .Normal)
        } else {
            sender.setTitle("Help User", forState: .Normal)
        }
    }
    
    // Mark: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("staff_helpq_cell", forIndexPath: indexPath) as! HelpQStaffCollectionViewCell
        configureCell(cell: cell)
        
        let helpQItem: HelpQ = fetchedResultsController.objectAtIndexPath(indexPath) as! HelpQ
        /* Configure cell with object parameters */
        cell.techLabel.text = helpQItem.technology
        cell.descLabel.text = helpQItem.desc
        cell.helpButton.referenceObject = helpQItem // Add a reference to the object in order to modify it
        
        // Set the button title depending on the status
        if helpQItem.isHelping.boolValue {
            cell.helpButton.setTitle("Stop Helping User", forState: .Normal)
        } else {
            cell.helpButton.setTitle("Help User", forState: .Normal)
        }
        cell.helpButton.addTarget(self, action: #selector(cellButtonPressed), forControlEvents: .TouchUpInside)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = helpQCollection.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "staff_helpq_header", forIndexPath: indexPath) as! HelpQHackerCollectionReusableView
        
        let helpQItem = fetchedResultsController.objectAtIndexPath(indexPath) as! HelpQ
        header.titleLabel.text = helpQItem.language
        
        return header
    }
    
    func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String) -> String? {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
