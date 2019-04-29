//
//  EnvelopeTableViewController.swift
//  Envelopes-HU
//
//  Created by Jeremy Campbell on 4/12/19.
//  Copyright © 2019 Jeremy Campbell. All rights reserved.
//

import UIKit


class EnvelopeTableViewController: UITableViewController {
    
    // Instantiate the Core Data Controller
    let envelopesController = EnvelopesController.getInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        //envelopesController.deleteAllCategories()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if let numCategories = envelopesController.getNumberOfCategories() {
           return numCategories
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let section = envelopesController.getNumberOfEnvelopes(inSection: section) {
            return section
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "envelopeCell", for: indexPath)

        let envelope = envelopesController.envelopeAtIndexPath(indexPath)
        cell.textLabel?.text = envelope.title
        cell.detailTextLabel?.text = "$" + String(format: "%.2f", envelope.totalAmount)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Custom header cell can go here, with section title and also an AddEnvelope button
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "categoryHeaderCell") as! CategoryHeaderCell
        
        if let sectionName = envelopesController.getNameForCategory(section: section) {
            headerCell.categoryName.text = sectionName
            headerCell.addEnvelope.sectionNumber = section
        }

        return headerCell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70.0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView {
        // Custom footer cell goes here, with the ability to delete the section entirely
        let footerCell = tableView.dequeueReusableCell(withIdentifier: "categoryFooterCell") as! CategoryFooterCell
        footerCell.delegate = self
        footerCell.categoryName = envelopesController.getNameForCategory(section: section)
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
            if (envelopesController.deleteEnvelope(atIndexPath: indexPath)) {
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.tableView.reloadData()
            } else {
                showMessage(message: "Envelope could not be deleted")
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
            if let destination = segue.destination as? TransactionTableViewController {
                // Get selected cell
                let currentCell = sender as! UITableViewCell
                
                // Populate the destination's values with the table cell's values
                destination.selectedEnvelopeTitle = currentCell.textLabel!.text!
                
                let envelope = envelopesController.getEnvelope(withTitle: currentCell.textLabel!.text!)!
                destination.selectedEnvelopeTotalAmount = Double(currentCell.detailTextLabel!.text!)
                destination.selectedEnvelopeStartingAmount = envelope.startingAmount
                
                // Delegate for unwinding
                destination.delegate = self
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
                    destination.section = section
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
        if (envelopesController.deleteCategory(withSectionNumber: sectionNumber)) {
            self.tableView.reloadData()
        } else {
            showMessage(message: "Could not delete category")
        }
    }
}

// Reloads the table data and core data when a view controller
// that was presented modally is dismissed. This is needed because
// the underlying table view does not disappear when a modal
// segue occurs, so none of the view life cycle functions are triggered
extension EnvelopeTableViewController: ModalViewDelegate {
    func modalDismissed() {
        // Reload the table
        self.tableView.reloadData()
    }
}
