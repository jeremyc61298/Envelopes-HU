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
    
    init(forContext viewContext: NSManagedObjectContext =
            (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext) {
        self.context = viewContext
        self.fetchedResultControllers = []
        self.fetchedResultControllers.append(envelopesFRC as! NSFetchedResultsController<NSManagedObject>)
        self.fetchedResultControllers.append(categoriesFRC as! NSFetchedResultsController<NSManagedObject>)
    }
    
    // ViewContext for the application
    let context: NSManagedObjectContext
    
    // Array of all the fetchedResultControllers for mass fetching
    var fetchedResultControllers: [NSFetchedResultsController<NSManagedObject>]
    
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
    
    // Debugging function which deletes all categories from core data
    fileprivate func deleteAllCategories(inContext context: NSManagedObjectContext) {
        let deleteFetch: NSFetchRequest<NSFetchRequestResult> = Category.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            let deleteError = error as NSError
            print ("Unable to delete")
            print ("\(deleteError), \(deleteError.localizedDescription)")
        }
    }
}
