//
//  EnvelopeTableViewController.swift
//  Envelopes-HU
//
//  Created by Jeremy Campbell on 4/12/19.
//  Copyright © 2019 Jeremy Campbell. All rights reserved.
//

import UIKit


class EnvelopeTableViewController: UITableViewController {
    
    // Instantiate the CoreDataManager
    let cdm = CoreDataManager.getInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        //cdm.deleteAllCategories()
        
        // Initialize all the fetchedResultsControllers in CoreDataManager
        cdm.fetchAll()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // TODO: Should this be numberOfObjects or sections.count?
        if let categories = cdm.categoriesFRC.fetchedObjects {
           return categories.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = cdm.envelopesFRC.sections {
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
        // TODO: This method does not work
        // Instead of this, I need a large change. I need to receive the data somewhere else,
        // in some function. Then I need to sort the data to represent my view. THEN I can
        // display the data correctly
        if let category = cdm.categoriesFRC.fetchedObjects?[indexPath.section] {
            if let envelope = category.envelopes?.allObjects[indexPath.row] as? Envelope {
                cell.textLabel?.text = envelope.title
                cell.detailTextLabel?.text = String(envelope.totalAmount)
            }
        }
        
//        if let numSectionsWithEnvelopes = cdm.envelopesFRC.sections?.count {
//            if (numSectionsWithEnvelopes < indexPath.section) {
//                let envelope = cdm.envelopesFRC.object(at: indexPath)
//
//                // Configure the cell...
//                cell.textLabel?.text = envelope.title
//                cell.detailTextLabel?.text = String(envelope.totalAmount)
//            }
//        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Custom header cell can go here, with section title and also an AddEnvelope button
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "categoryHeaderCell") as! CategoryHeaderCell
        
        // Populate category name
        if let sections = cdm.categoriesFRC.fetchedObjects {
            let currentSection = sections[section]
            headerCell.categoryName.text = currentSection.title
            
            // This here is ugly
            headerCell.addEnvelope.sectionNumber = section
        }

        return headerCell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView {
        // Custom footer cell goes here, with the ability to delete the section entirely
        let footerCell = tableView.dequeueReusableCell(withIdentifier: "categoryFooterCell") as! CategoryFooterCell
        footerCell.delegate = self
        footerCell.categoryName = cdm.categoriesFRC.fetchedObjects?[section].title
        footerCell.sectionNumber = section
        return footerCell
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50.0
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source only if it is successfully deleted from CoreData
            if let envelopeToDelete = cdm.envelopesFRC.fetchedObjects?[indexPath.row] {
                if (cdm.deleteEnvelope(envelopeToDelete)) {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    self.tableView.reloadData()
                } else {
                    showMessage(message: "Envelope could not be deleted")
                }
                
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

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
    
    // ---- Error Handling ---- //
    
    func showMessage(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Okay", style: .default))
        self.present(alert, animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "envelopeSegue" {
            if let destination = segue.destination as? EnvelopeViewController{
                // Get selected cell, its index and the section header
                let currentCell = sender as! UITableViewCell
                let indexPath = self.tableView.indexPath(for: currentCell)!
                let header = self.tableView.headerView(forSection: indexPath.section)
                
                // Populate the destination's values with the table cell's values
                destination.selectedEnvelopeName = currentCell.textLabel!.text!
                destination.selectedCategoryName = header?.textLabel!.text!
            }
        } else if segue.identifier == "newCategorySegue" {
            if let nav = segue.destination as? UINavigationController {
                if let destination = nav.viewControllers.first as? CreateCategoryViewController {
                    destination.delegate = self
                }
            }
        } else if segue.identifier == "newEnvelopeSegue" {
            if let nav = segue.destination as? UINavigationController {
                if let destination = nav.viewControllers.first as? CreateEnvelopeViewController {
                    let section = (sender as! AddEnvelopeButton).sectionNumber
                    destination.delegate = self
                    destination.category = cdm.categoriesFRC.fetchedObjects![section!]
                }
            }
        }
    }
}

// CategoryFooterCellDelegate
// Handler called when the user wants to delete a category
extension EnvelopeTableViewController: CategoryFooterCellDelegate {
    func categoryFooterCell(_ categoryFooterCell: CategoryFooterCell) {
        let categoryNameToDelete = categoryFooterCell.categoryName!
        let sectionNumber = categoryFooterCell.sectionNumber!
        
        // Check if the user really wants to delete the category with an action sheet
        let requestToDelete = UIAlertController(title: nil,
                                              message: "Delete \(categoryNameToDelete)",
                                              preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete",
                                         style: .destructive,
                                         handler: {(action) in self.deleteCategory(sectionNumber)})
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        requestToDelete.addAction(deleteAction)
        requestToDelete.addAction(cancelAction)
        self.present(requestToDelete, animated: true, completion: nil)
    }

    func deleteCategory(_ sectionNumber: Int) {
        // Get category
        if let categoryToDelete = cdm.categoriesFRC.fetchedObjects?[sectionNumber] {
            if (!cdm.deleteCategory(categoryToDelete)) {
                showMessage(message: "Could not delete category")
            } else {
                self.tableView.reloadData()                
            }
        }
    }
}

// Reloads the table data and core data when a view controller
// that was presented modally is dismissed. This is needed because
// the underlying table view does not disappear when a modal
// segue occurs, so none of the view life cycle functions are triggered
extension EnvelopeTableViewController: ModalViewDelegate {
    func modalDismissed() {
        // Update the model and reload the table
        self.tableView.reloadData()
    }
}
