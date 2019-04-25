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
    private static let envelopesController = EnvelopesController()
    
    static func getInstance() -> EnvelopesController {
        return envelopesController
    }
    
    private init(){
        
    }
    
    // Managed Object Context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
        if let categoryTitle = getNameForCategory(section: section){
            if let category = fetchCategory(withTitle: categoryTitle){
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
    
    func getNumberOfCategories() -> Int? {
        return fetchedEnvelopesController.sections?.count
    }
    
    func getNumberOfEnvelopes(inSection section: Int) -> Int? {
        return fetchedEnvelopesController.sections?[section].numberOfObjects
    }
    
    func getNameForCategory(section: Int) -> String? {
        return fetchedEnvelopesController.sections?[section].name
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
        } catch {
            let fetchError = error as NSError
            print("Could not retrieve objects")
            print ("\(fetchError), \(fetchError.localizedDescription)")
        }
    }
}


