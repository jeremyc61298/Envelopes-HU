//
//  CreateCategoryViewController.swift
//  Envelopes-HU
//
//  Created by Jeremy Campbell on 4/19/19.
//  Copyright © 2019 Jeremy Campbell. All rights reserved.
//

import UIKit
import CoreData

class CreateCategoryViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var categoryName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        categoryName.delegate = self
    }
    
    @IBAction func cancelCreation(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func createCategory(_ sender: UIBarButtonItem) {
        // Create a new category and place it in Core Data
        // Connect to the model in core data
        if (categoryName.text != "") {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            // First check to make sure that there aren't any categories with the new name
            let isUnique = checkForDuplicates(inContext: context)
            
            if (!isUnique) {
                showMessage(message: "There is already a category by that name")
            } else {
                // Create a new Category object and save it to the DB
                let category = Category(context: context)
                category.title = categoryName.text!
                
                do {
                    try context.save()
                } catch {
                    print(error)
                }
            }
        } else {
            showMessage(message: "Please enter a valid category name")
        }
        
        // Now go back to the main screen
    }

    func checkForDuplicates(inContext context: NSManagedObjectContext) -> Bool {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        do {
            let matches = try context.fetch(request)
            for match in matches {
                if (match.title == categoryName.text) {
                    return false
                }
            }
        } catch {
            print(error)
        }
        return true
    }
    
    func showMessage(message: String) {
        let alert = UIAlertController(title: "Invalid name", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Okay", style: .default))
        self.present(alert, animated: true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
