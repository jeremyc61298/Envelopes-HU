//
//  TransactionTableViewController.swift
//  Envelopes-HU
//
//  Created by Jeremy Campbell on 4/25/19.
//  Copyright © 2019 Jeremy Campbell. All rights reserved.
//

import UIKit

class TransactionTableViewController: UITableViewController, UITextFieldDelegate {
    
    // CoreData Controller
    let envelopesController = EnvelopesController.getInstance()
    
    // Delegate for unwinding
    var delegate: ModalViewDelegate?
    
    // Envelope Information
    var selectedEnvelopeTitle: String!
    var selectedEnvelopeTotalAmount: Double!
    var selectedEnvelopeStartingAmount: Double!
    
    // Model
    var transactions: [Transaction]?
    
    // View outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.titleTextField.text = selectedEnvelopeTitle
        
        // Populate Transactions and calculate totals
        self.reloadTransactions()
        self.amountLabel.text = "$" + String(format: "%.2f", calculateTotalAmount(fromStartingAmount: selectedEnvelopeStartingAmount))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (self.delegate != nil) {
            self.delegate?.modalDismissed()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let trans = transactions {
            return trans.count
        }
         return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath)

        // Configure the cell...
        if let trans = transactions {
            let currentTransaction = trans[indexPath.row]
            // Don't know why the title is optional, it should not be
            cell.textLabel?.text = currentTransaction.title
            cell.detailTextLabel?.text = "$" + String(format: "%.2f", currentTransaction.amount)
            if (currentTransaction.isExpense) {
                cell.detailTextLabel?.text = "-" + cell.detailTextLabel!.text!
                cell.detailTextLabel?.textColor = .red
            } else {
                cell.detailTextLabel?.text = "+" + cell.detailTextLabel!.text!
                cell.detailTextLabel?.textColor = .init(red: 45/255, green: 155/255, blue: 77/255, alpha: 1)
            }
        }

        return cell
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
            // Delete the row from the data source
            if let trans = transactions {
                if (envelopesController.deleteTransaction(trans[indexPath.row])) {
                    self.reloadTransactions()
                    
                    // Then delete the row from the table
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    self.tableView.reloadData()
                } else {
                    self.showMessage(message: "Could not delete transaction")
                }
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "transactionHeaderCell") as! TransactionHeaderCell
        headerCell.delegate = self
        return headerCell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "newTransactionSegue" {
            if let nav = segue.destination as? UINavigationController {
                if let destination = nav.viewControllers.first as? CreateTransactionViewController {
                    destination.delegate = self
                    destination.currentEnvelope = self.selectedEnvelopeTitle
                }
            }
        } else if segue.identifier == "viewTransactionSegue" {
            if let nav = segue.destination as? UINavigationController {
                if let destination = nav.viewControllers.first as? CreateTransactionViewController {
                    let currentCell = sender as! UITableViewCell
                    let indexPath = self.tableView.indexPath(for: currentCell)!
                    
                    destination.delegate = self
                    destination.currentEnvelope = self.selectedEnvelopeTitle
                    if let trans = transactions {
                        destination.transaction = trans[indexPath.row]
                    }
                }
            }
        }
    }
    
    // ---- Message Handling ---- //
    
    func showMessage(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Okay", style: .default))
        self.present(alert, animated: true)
    }
    
    // ---- Data Sync ---- //

    func reloadTable() {
        reloadTransactions()
        self.tableView.reloadData()
    }
    
    func reloadTransactions() {
        transactions = envelopesController.fetchTransactions(forEnvelope: selectedEnvelopeTitle)
        self.updateEnvelopeTotal()
    }
    
    func updateEnvelopeTotal() {
        // Calculate Total
        let newTotal = calculateTotalAmount(fromStartingAmount: selectedEnvelopeStartingAmount)
        self.amountLabel.text = "$" + String(format: "%.2f", newTotal)
        
        // Update envelope
        let errMsg = envelopesController.updateEnvelope(withOldTitle: selectedEnvelopeTitle, toNewTitle: selectedEnvelopeTitle, toNewStartingAmount: selectedEnvelopeStartingAmount, toNewTotalAmount: newTotal)
        if (errMsg != nil) {
            showMessage(message: "There was a problem updating envelope information")
        } else {
            selectedEnvelopeTotalAmount = newTotal
        }
    }
    
    func calculateTotalAmount(fromStartingAmount amount: Double) -> Double {
        var total = amount
        if let trans = transactions {
            for transaction in trans {
                if transaction.isExpense {
                    total -= transaction.amount
                } else {
                    total += transaction.amount
                }
            }
        }
        return total
    }
}

extension TransactionTableViewController: ModalViewDelegate {
    func modalDismissed() {
        self.reloadTable()
    }
}

extension TransactionTableViewController: TransactionHeaderCellDelegate {
    func clearAllTransactions() {
        // Check if the user really wants to delete the all transactions
        // and if they would like to rollover their current total or start
        // from original starting total
        
        let requestToDelete = UIAlertController(title: nil,
                                                message: "Both options will delete all transactions, but rolling over the current balance will update the starting balance to be the current balance",
            preferredStyle: .actionSheet)
        let deleteRolloverAction = UIAlertAction(title: "Rollover Current Balance",
                                         style: .destructive,
                                         handler: {action in self.deleteAndRollover()})
        let deleteRestoreAction = UIAlertAction(title: "Restore Original Balance",
                                                style: .destructive,
                                                handler: {action in self.deleteAllTransactions()})
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        requestToDelete.addAction(deleteRolloverAction)
        requestToDelete.addAction(deleteRestoreAction)
        requestToDelete.addAction(cancelAction)
        self.present(requestToDelete, animated: true, completion: nil)
    }
    
    fileprivate func deleteAndRollover() {
        // Update the envelope with the new starting value, which is the old totalvalue
        self.selectedEnvelopeStartingAmount = self.selectedEnvelopeTotalAmount
        self.deleteAllTransactions()
    }
    
    fileprivate func deleteAllTransactions() {
        var failedToDelete = false
        if let trans = transactions {
            for transaction in trans {
                if (!envelopesController.deleteTransaction(transaction)) {
                    failedToDelete = true
                }
            }
        }
        if (failedToDelete) {
            showMessage(message: "Something went wrong when deleting the transactions")
        }
        self.reloadTable()
    }
}
