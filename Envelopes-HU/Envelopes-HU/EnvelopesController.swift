//
//  EnvelopesController.swift
//  Envelopes-HU
//
//  Created by Jeremy Campbell on 4/25/19.
//  Copyright © 2019 Jeremy Campbell. All rights reserved.
//

import UIKit
import CoreData

// Used to display envelopes in the tableview
class EnvelopesController {
    
    // ---- Singleton ---- //
    
    private static let envelopesController = EnvelopesController()
    
    static func getInstance() -> EnvelopesController {
        return envelopesController
    }
    
    private init(){
        
    }
    
    // Managed Object Context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Save to the current context in the controller
    // Returns whether or not it was successful
    func saveContext(errorMsg: String) -> Bool {
        do {
            try context.save()
            return true
        } catch {
            let saveError = error as NSError
            print(errorMsg)
            print("\(saveError), \(saveError.localizedDescription)")
            return false
        }
    }
    
    // Refetch to the controllers
    func reloadData() {
        do {
            try fetchedEnvelopesController.performFetch()
            try fetchedCategoriesController.performFetch()
            mapEnvelopeSectionsToCategory()
        } catch {
            let fetchError = error as NSError
            print("Could not retrieve objects")
            print ("\(fetchError), \(fetchError.localizedDescription)")
        }
    }
    
    // ---- Envelopes ---- //
    
    fileprivate lazy var fetchedEnvelopesController: NSFetchedResultsController<Envelope> = {
        let fetchRequest: NSFetchRequest<Envelope> = Envelope.fetchRequest()
        
        fetchRequest.relationshipKeyPathsForPrefetching = ["category"]
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "internalOrder", ascending: false)
        ]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: "category.title", cacheName: nil)
        
        try! controller.performFetch()
        
        return controller
    }()
    
    private var map: [Int] = []
    
    private func mapEnvelopeSectionsToCategory() {
        // Don't forget to clear the map before I start appending
        if let categories = fetchedCategoriesController.fetchedObjects {
            map.removeAll()
            for i in 0..<categories.count {
                if categories[i].envelopes!.count != 0 {
                    // Category is not empty
                    map.append(i)
                }
            }
        }
    }
    
    func fetchedEnvelopes() -> [Envelope] {
        return fetchedEnvelopesController.fetchedObjects ?? []
    }
    
    func envelopeAtIndexPath(_ indexPath: IndexPath) -> Envelope {
        if map.isEmpty {
            mapEnvelopeSectionsToCategory()
        }
        let mappedSection = map.firstIndex(of: indexPath.section)!
        let mappedIndexPath = IndexPath(row: indexPath.row, section: mappedSection)
        return fetchedEnvelopesController.object(at: mappedIndexPath)
    }
    
    func getEnvelope(withTitle title: String) -> Envelope? {
        return fetchedEnvelopesController.fetchedObjects?.filter({$0.title == title}).first
    }
    
    func addEnvelope(toSection section: Int, withTitle title: String, withAmount amount: Double?) -> String? {
        if let category = fetchedCategoriesController.fetchedObjects?[section] {
            // Validate
            let errMsg = validateEnvelope(withTitle: title, withStartingAmount: amount, withTotalAmount: amount, ignoreUnique: false)
            if (errMsg != nil) {
                return errMsg
            }
            
            let newEnvelope = Envelope(context: self.context)
            newEnvelope.title = title
            newEnvelope.startingAmount = amount!
            newEnvelope.totalAmount = amount!
            newEnvelope.category = category
            
            let didSave = self.saveContext(errorMsg: "Could not create envelope")
            if (!didSave) {
                return "Could not create envelope"
            }
            
            // Successful
            self.reloadData()
            return nil
        }
        return "Oops, we had a problem creating your envelope"
    }
    
    private func validateEnvelope(withTitle title: String, withStartingAmount startingAmount: Double?, withTotalAmount totalAmount: Double?, ignoreUnique: Bool) -> String? {
        if (title == "") {
            return "Please enter a valid title"
        }
        
        if (title.count > 20) {
            return "Title name too long"
        }
        
        if (!ignoreUnique) {
            let isUnique = checkForDuplicateEnvelope(withTitle: title)
            if (!isUnique) {
                return "There is already an envelope with that title"
            }
        }
        
        if (startingAmount == nil) {
            return "Starting amount cannot be empty"
        }
        
        if (startingAmount! < 0.0) {
            return "Starting amount must be positive"
        }
        
        if (totalAmount == nil) {
            return "Total amount cannot be empty"
        }
        
        if (totalAmount! < 0.0) {
            return "Total amount must be positive"
        }
        
        
        return nil
    }
    
    func checkForDuplicateEnvelope(withTitle title: String) -> Bool {
        if let envelopes = fetchedEnvelopesController.fetchedObjects {
            for envelope in envelopes {
                if (envelope.title == title) {
                    return false
                }
            }
        }
        return true
    }
    
    func updateEnvelope(withOldTitle oldTitle: String, toNewTitle newTitle: String, toNewStartingAmount newStartingAmount: Double?, toNewTotalAmount newTotalAmount: Double?) -> String? {
        
        let errMsg = validateEnvelope(withTitle: newTitle, withStartingAmount: newStartingAmount, withTotalAmount: newTotalAmount, ignoreUnique: true)
        if (errMsg != nil) {
            return errMsg
        }
        
        if let envelopeToUpdate = self.getEnvelope(withTitle: oldTitle) {
            envelopeToUpdate.title = newTitle
            envelopeToUpdate.startingAmount = newStartingAmount!
            envelopeToUpdate.totalAmount = newTotalAmount!
        } else {
            return "Could not find envelope to update"
        }
        
        let didSave = self.saveContext(errorMsg: "Could not update envelope")
        if (!didSave) {
            return "Could not update envelope"
        }
        
        // Successful
        self.reloadData()
        return nil
    }
    
    func deleteEnvelope(atIndexPath indexPath: IndexPath) -> Bool {
        let envelopeToDelete = fetchedEnvelopesController.object(at: indexPath)
        context.delete(envelopeToDelete)
        if(saveContext(errorMsg: "Could not delete envelope")) {
            self.reloadData()
            return true
        }
        return false
    }
    
    // ---- Categories ---- //
    
    fileprivate lazy var fetchedCategoriesController: NSFetchedResultsController<Category> = {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        // This sort descriptor MUST be the same as one of the Envelope Descriptors to
        // make sure the 2 controllers are parallel
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        
        try! controller.performFetch()
        
        return controller
        
    }()
    
    func getNumberOfCategories() -> Int? {
        return fetchedCategoriesController.fetchedObjects?.count
    }
    
    func getNumberOfEnvelopes(inSection section: Int) -> Int? {
        return fetchedCategoriesController.fetchedObjects?[section].envelopes?.count
    }
    
    func getNameForCategory(section: Int) -> String? {
        return fetchedCategoriesController.fetchedObjects?[section].title
    }
    
    func fetchCategory(withTitle title: String) -> Category? {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title = %@", title)
        
        do {
            // There should only be one becasue category titles are unique
            return try context.fetch(fetchRequest).first
        } catch {
            let fetchError = error as NSError
            print("Could not retrieve category")
            print ("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        return nil
    }
    
    func addCategory(withTitle title: String) -> String? {
        // Check for empty string or too long
        let errMsg = validateCategory(withTitle: title)
        if (errMsg != nil) {
            return errMsg
        }
        
        // Create category and save
        let category = Category(context: context)
        category.title = title
        
        let didSave = saveContext(errorMsg: "Could not create new category")
        if (!didSave) {
            return "Could not create category"
        }
        
        // Successful, refresh the controller
        // Side note, why do I have to cast to this?
        self.reloadData()
        
        return nil
    }
    
    private func validateCategory(withTitle title: String) -> String? {
        if (title == "") {
            return "Please enter a valid title"
        } else if (title.count >= 20) {
            return "Title too long"
        }
        
        let isUnique = checkForDuplicateCategory(withTitle: title)
        if (!isUnique) {
            return "There is already a category with that title"
        }
        return nil
    }
    
    // Checks in the fetchedResultsController if there is any category with
    // the new name
    func checkForDuplicateCategory(withTitle title: String) -> Bool {
        if let categories = fetchedCategoriesController.fetchedObjects {
            for category in categories {
                if (category.title == title) {
                    return false
                }
            }
        }
        return true
    }
    
    func deleteCategory(withSectionNumber section: Int) -> Bool {
        if let category = fetchedCategoriesController.fetchedObjects?[section] {
            context.delete(category)
            if (saveContext(errorMsg: "Could not delete category")) {
                self.reloadData()
                return true
            }
        }
        return false
    }
    
    // Debug function
    func deleteAllCategories() {
        if let categories = fetchedCategoriesController.fetchedObjects {
            for category in categories {
                context.delete(category)
            }
            let _ = saveContext(errorMsg: "Could not delete all categories")
            self.reloadData()
        }
    }
    
    // ---- Transactions ---- //
    
    func fetchTransactions(forEnvelope envelopeTitle: String) -> [Transaction]? {
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "envelope.title = %@", envelopeTitle)
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false)
        ]
        
        do {
            let transactions = try context.fetch(fetchRequest)
            return transactions
        } catch {
            let fetchError = error as NSError
            print("Could not retrieve transactions for envelope \(envelopeTitle)")
            print ("\(fetchError), \(fetchError.localizedDescription)")
        }
        return nil
    }
    
    // Validate user input and then save a new transaction to CoreData
    // Return an error message if validation fails
    func addTransaction(toEnvelope envelopeTitle: String,
                        withTitle title: String,
                        withAmount amount: Double?,
                        withDate date: Date?,
                        withNote note: String?,
                        isExpense: Bool) -> String? {
        
        let errMsg = validateTransaction(title, amount, date, isExpense, envelopeTitle)
        if (errMsg != nil) {
            // Transaction was invalid, return with error message
            return errMsg
        }
        
        let transaction = Transaction(context: self.context)
        transaction.envelope = self.getEnvelope(withTitle: envelopeTitle)
        transaction.title = title
        transaction.amount = amount!
        transaction.date = date
        transaction.note = note
        transaction.isExpense = isExpense
        
        
        let didSave = saveContext(errorMsg: "Could not add transaction to envelope \(envelopeTitle)")
        if (!didSave) {
            // Something went wrong with CoreData
            return "Could not add transaction"
        }
        
        return nil
    }
    
    func validateTransaction(_ title: String, _ amount: Double?, _ date: Date?, _ isExpense: Bool, _ envelopeTitle: String) -> String? {
        if (title == "") {
            return "Please enter a valid title"
        } else if (title.count > 20) {
            return "Title too long"
        }
        
        if let err = validateAmount(amount) {
            return err
        }
        
        if (date == nil) {
            return "Please enter date"
        }
        
        // Make sure the transaction doesn't drop the envelope total below zero
        if (isExpense) {
            let envelope = self.getEnvelope(withTitle: envelopeTitle)
            
            if ((envelope!.totalAmount - amount!) < 0) {
                return "Lack of funds for an expense of $\(String(format: "%.2f", amount!))"
            }
        }
        
        // Successful validation
        return nil
    }
    
    private func validateAmount(_ amount: Double?) -> String? {
        if (amount == nil) {
            return "Please enter a valid amount"
        } else if (amount! < 0.0) {
            return "Please enter a positive amount"
        }
        return nil
    }
    
    func updateTransaction(_ transaction: Transaction,
                           withTitle title: String,
                           withAmount amount: Double?,
                           withDate date: Date?,
                           withNote note: String?,
                           isExpense: Bool) -> String? {
        // Specifically when updating, need to check whether the isExpense field changed from false to true
        if (isExpense && !transaction.isExpense) {
            let envelope = self.getEnvelope(withTitle: transaction.envelope!.title!)
            if let errMsg = validateAmount(amount) {
                return errMsg
            }
            if ((envelope!.totalAmount - amount! - amount!) < 0) {
                return "Lack of funds for an expense of $\(String(format: "%.2f", amount!))"
            }
        }
        
        
        let errMsg = validateTransaction(title, amount, date, isExpense, transaction.envelope!.title!)
        if (errMsg != nil) {
            // Transaction was invalid, return with error message
            return errMsg
        }
        
        transaction.title = title
        transaction.amount = amount!
        transaction.date = date!
        transaction.note = note
        transaction.isExpense = isExpense
        
        if (!saveContext(errorMsg: "Could not update transaction")) {
            return "Something went wrong when updating the transaction"
        }
    
        self.reloadData()
        return nil
    }

    
    func deleteTransaction(_ transaction: Transaction) -> Bool {
        context.delete(transaction)
        if (saveContext(errorMsg: "Could not delete transaction")) {
            self.reloadData()
            return true
        }
            return false
    }
}
