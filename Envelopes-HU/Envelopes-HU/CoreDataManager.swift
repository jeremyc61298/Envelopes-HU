//
//  CoreDataManager.swift
//  Envelopes-HU
//
//  Created by Jeremy Campbell on 4/23/19.
//  Copyright © 2019 Jeremy Campbell. All rights reserved.
//

import CoreData
import UIKit

class CoreDataManager {
    
    private static let cdmInstance = CoreDataManager()
    
    static func getInstance() -> CoreDataManager {
        return cdmInstance
    }
    
    private init() {
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.fetchedResultControllers = []
        self.fetchedResultControllers.append(envelopesFRC as! NSFetchedResultsController<NSManagedObject>)
        self.fetchedResultControllers.append(categoriesFRC as! NSFetchedResultsController<NSManagedObject>)
    }
    
    // ViewContext for the application
    let context: NSManagedObjectContext
    
    // ---- FetchedResultControllers ---- //
    
    // Array of all the fetchedResultControllers for mass fetching
    private var fetchedResultControllers: [NSFetchedResultsController<NSManagedObject>]
    
    // FecthedResultsController for Envelope entity
    lazy var envelopesFRC: NSFetchedResultsController<Envelope> = {
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
    lazy var categoriesFRC: NSFetchedResultsController<Category> = {
        // Get all the Categories from CoreData
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        // Sort by something here
        let sortTitle = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortTitle]
        
        // Create Controller
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)

        return frc
    }()
    
    // ---- Fetching ---- //
    
    func fetchAll() {
        for controller in fetchedResultControllers {
            fetchObjects(toController: controller)
        }
    }
    
    func fetchObjects(toControllers controllers: NSFetchedResultsController<NSManagedObject>...) {
        for controller in controllers {
            fetchObjects(toController: controller)
        }
    }
    
    // Performs fetchRequest for a specific controller
    func fetchObjects(toController controller: NSFetchedResultsController<NSManagedObject>) {
        do {
            try controller.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Could not retrieve objects")
            print ("\(fetchError), \(fetchError.localizedDescription)")
        }
    }
    
    // Save to the current context in the CoreDataManager
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
    
    // ---- Category ---- //
    
    // Tries to create a new category. If this fails at any point, an
    // error message is generated and returned. Message is nil if success
    func createCategory(withTitle title: String) -> String? {
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
        self.fetchObjects(toController: self.categoriesFRC as! NSFetchedResultsController<NSManagedObject>)
    
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
        if let categories = categoriesFRC.fetchedObjects {
            for category in categories {
                if (category.title == title) {
                    return false
                }
            }
        }
        return true
    }
    
    // Try to delete the category, return whether it was successful
    // and reload the categoryResultsController
    func deleteCategory(_ category: Category) -> Bool {
        context.delete(category)
        if (saveContext(errorMsg: "Could not delete category")) {
            self.fetchObjects(toController: self.categoriesFRC as! NSFetchedResultsController<NSManagedObject>)
            return true
        }
            return false
    }
    
    // Debugging function which deletes all categories from core data
    func deleteAllCategories() {
        let deleteFetch: NSFetchRequest<NSFetchRequestResult> = Category.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try self.context.execute(deleteRequest)
            try context.save()
        } catch {
            let deleteError = error as NSError
            print ("Unable to delete categories")
            print ("\(deleteError), \(deleteError.localizedDescription)")
        }
    }
    
    // ---- Envelope ---- //
    
    // Try to create the envelope, return some error messsage if not successful,
    // else return nil
    func createEnvelope(inCategory category: Category, withTitle title: String, withAmount amount: Double?) -> String? {
        // Validate
        let errMsg = validateEnvelope(withTitle: title, withAmount: amount)
        if (errMsg != nil) {
            return errMsg
        }
        
        // Create and save
        let envelope = Envelope(context: self.context)
        envelope.title = title
        envelope.totalAmount = amount!
        envelope.category = category
        
        let didSave = self.saveContext(errorMsg: "Could not create envelope")
        if (!didSave) {
            return "Could not create envelope"
        }
        
        // Success
        self.fetchObjects(toController: self.envelopesFRC as! NSFetchedResultsController<NSManagedObject>)
        return nil
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
        if let envelopes = envelopesFRC.fetchedObjects {
            for envelope in envelopes {
                if (envelope.title == title) {
                    return false
                }
            }
        }
        return true
    }
    
    func deleteEnvelope(_ envelope: Envelope) -> Bool {
        context.delete(envelope)
        let didDelete = saveContext(errorMsg: "Could not delete envelope")
        if (didDelete) {
            self.fetchObjects(toController: envelopesFRC as! NSFetchedResultsController<NSManagedObject>)
            return true
        }
        return false
    }
}
