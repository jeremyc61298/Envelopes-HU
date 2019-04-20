//
//  EnvelopeTableViewController.swift
//  Envelopes-HU
//
//  Created by Jeremy Campbell on 4/12/19.
//  Copyright © 2019 Jeremy Campbell. All rights reserved.
//

import UIKit
import CoreData

class EnvelopeTableViewController: UITableViewController {
    
    // ManagedObjectContext for this application
    var context: NSManagedObjectContext!
    
    // FecthedResultsController for Envelope entity
    fileprivate lazy var envelopesFetchedResultsController: NSFetchedResultsController<Envelope> = {
        // Get all the Envelopes from CoreData
        let request: NSFetchRequest<Envelope> = Envelope.fetchRequest()
        
        // Must use a sort descriptor here
        let sortTitle = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortTitle]
        
        // Create fetchResultsController
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.context, sectionNameKeyPath: "category.title", cacheName: nil)
        
        return frc
    }()
    
    // FetchResultsController for Category entity
    fileprivate lazy var categoriesFetchedResultsController: NSFetchedResultsController<Category> = {
        // Get all the Categories from CoreData
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        // Sort by something here
        let sortTitle = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortTitle]
        
        // Create Controller
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        // Get ManagedObjectContext
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Perform fetch on fetchRequestController
        fetchEnvelopesToController()
        fetchCategoriesToController()
    }
    
    fileprivate func fetchEnvelopesToController() {
        do {
            try envelopesFetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Could not retrieve envelopes")
            print ("\(fetchError), \(fetchError.localizedDescription)")
        }
    }

    fileprivate func fetchCategoriesToController() {
        do {
            try categoriesFetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Could not retrieve categories")
            print ("\(fetchError), \(fetchError.localizedDescription)")
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // TODO: Should this be numberOfObjects or sections.count?
        if let categories = categoriesFetchedResultsController.fetchedObjects {
           return categories.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = envelopesFetchedResultsController.sections {
            if section < sections.count {
                let currentSectionInfo = sections[section]
                return currentSectionInfo.numberOfObjects
            }
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "envelopeCell", for: indexPath)
        
        // Make sure that the envelope actually exists
        if let numSectionsWithEnvelopes = envelopesFetchedResultsController.sections?.count {
            if (numSectionsWithEnvelopes < indexPath.section) {
                let envelope = envelopesFetchedResultsController.object(at: indexPath)
                
                // Configure the cell...
                cell.textLabel?.text = envelope.title
                cell.detailTextLabel?.text = String(envelope.totalAmount)
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = categoriesFetchedResultsController.fetchedObjects {
            let currentSection = sections[section]
            return currentSection.title
        }
        return nil
    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        // Custom header cell can go here, with section title and also an AddEnvelope button
//    }
    
//    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView {
//        // Custom footer cell goes here, with the ability to delete the section entirely
//    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "envelopeSegue" {
            if let destination = segue.destination as? EnvelopeViewController{
                // Get selected cell, its index, and header
                let currentCell = sender as! UITableViewCell
                let indexPath = self.tableView.indexPath(for: currentCell)!
                let header = self.tableView.headerView(forSection: indexPath.section)
                
                // Populate the destination's values with the table cell's values
                destination.selectedEnvelopeName = currentCell.textLabel!.text!
                destination.selectedCategoryName = header?.textLabel!.text!
            }
        } else if segue.identifier == "newCategorySegue" {
//            if let destination = segue.destination as? CreateCategoryViewController {
//                // Possibly do something here to prepare for creating a new category
//            }
        }
    }
    

}
