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
    
    func fetchedEnvelopes() -> [Envelope] {
        return fetchedEnvelopesController.fetchedObjects ?? []
    }
    
    func envelopeAtIndexPath(_ indexPath: IndexPath) -> Envelope {
        return fetchedEnvelopesController.object(at: indexPath)
    }
    
    func addEnvelope(toSection section: Int, withTitle title: String, withAmount amount: Double?) -> String? {
        if let category = fetchedCategoriesController.fetchedObjects?[section] {
            // Validate
            let errMsg = validateEnvelope(withTitle: title, withAmount: amount)
            if (errMsg != nil) {
                return errMsg
            }
            
            let newEnvelope = Envelope(context: self.context)
            newEnvelope.title = title
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
    
    private func validateEnvelope(withTitle title: String, withAmount amount: Double?) -> String? {
        if (title == "") {
            return "Please enter a valid title"
        }
        
        if (title.count > 20) {
            return "Title name too long"
        }
        
        let isUnique = checkForDuplicateEnvelope(withTitle: title)
        if (!isUnique) {
            return "There is already an envelope with that title"
        }
        
        if (amount == nil) {
            return "Please enter a valid amount"
        }
        
        if (amount! < 0.0) {
            return "Please enter a positive amount"
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
    
    func reloadData() {
        do {
            try fetchedEnvelopesController.performFetch()
            try fetchedCategoriesController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Could not retrieve objects")
            print ("\(fetchError), \(fetchError.localizedDescription)")
        }
    }
}
