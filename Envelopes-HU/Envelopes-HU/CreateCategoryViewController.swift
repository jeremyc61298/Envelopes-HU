//
//  CreateCategoryViewController.swift
//  Envelopes-HU
//
//  Created by Jeremy Campbell on 4/19/19.
//  Copyright © 2019 Jeremy Campbell. All rights reserved.
//

import UIKit

class CreateCategoryViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var categoryName: UITextField!
    var delegate: ModalViewDelegate!
    let envelopesController = EnvelopesController.getInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        categoryName.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.delegate != nil {
            self.delegate.modalDismissed()
        }
    }
    
    @IBAction func cancelCreation(_ sender: UIBarButtonItem) {
        // Go back to the main nav controller
        dismiss(animated: true)
    }
    
    // Create a new category and place it in Core Data
    // Connect to the model in core data
    @IBAction func createCategory(_ sender: UIBarButtonItem) {
        if let errMsg = envelopesController.addCategory(withTitle: categoryName.text!) {
            showMessage(message: errMsg)
        } else {
            // Go back to the main controller
            dismiss(animated: true)
        }
    }
    
    func showMessage(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
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
