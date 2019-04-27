//
//  CreateTransactionViewController.swift
//  Envelopes-HU
//
//  Created by Jeremy Campbell on 4/26/19.
//  Copyright © 2019 Jeremy Campbell. All rights reserved.
//

import UIKit

class CreateTransactionViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    // Core Data Controller
    let envelopesController = EnvelopesController.getInstance()
    
    var delegate: ModalViewDelegate!
    var currentEnvelope: String!
    
    // From viewTransactionSegue
    var transaction: Transaction?
    
    // View outlets
    @IBOutlet weak var titleTextfield: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var isExpense: UISwitch!
    @IBOutlet weak var notesTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureNotesTextView()
        
        titleTextfield.delegate = self
        amountTextField.delegate = self
        dateTextField.delegate = self
        notesTextView.delegate = self
        
        setPlaceHolders()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.delegate != nil {
            self.delegate.modalDismissed()
        }
    }
    
    // Make the textview look like the textfields
    fileprivate func configureNotesTextView() {
        let borderGray = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        self.notesTextView.layer.borderColor = borderGray.cgColor
        self.notesTextView.layer.borderWidth = 0.5
        self.notesTextView.layer.cornerRadius = 5
    }
    
    func setPlaceHolders() {
        
        if let trans = transaction {
            titleTextfield.text = trans.title
            amountTextField.text = String(trans.amount)
            dateTextField.text = formatDateForDisplay(date: trans.date)
            isExpense.isOn = trans.isExpense
            notesTextView.text = trans.note
        }
    }
    
    @IBAction func cancelCreation(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func createTransaction(_ sender: UIBarButtonItem) {
        let date = stringToDate(dateString: dateTextField.text)

        // Check if transaction is being updated or created
        if let trans = transaction {
            if let errMsg = envelopesController.updateTransaction(trans, withTitle: titleTextfield.text!, withAmount: Double(amountTextField.text!), withDate: date, withNote: notesTextView.text, isExpense: isExpense.isOn) {
                showMessage(message: errMsg)
            } else {
                dismiss(animated: true)
            }
        } else {
            if let errMsg = envelopesController.addTransaction(toEnvelope: currentEnvelope, withTitle: titleTextfield.text!, withAmount: Double(amountTextField.text!), withDate: date, withNote: notesTextView.text, isExpense: isExpense.isOn) {
                
                // Alert the user to the error
                showMessage(message: errMsg)
            } else {
                // Success, Dismiss View
                dismiss(animated: true)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // ---- Message Handling ---- //
    
    func showMessage(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Okay", style: .default))
        self.present(alert, animated: true)
    }
    
    // ---- TextFieldDelegate ---- //
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Create a date picker
        if (textField == self.dateTextField) {
            // Create a date picker
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(self.updateTextInField(sender:)), for: .valueChanged)
            
            // Create toolbar
            let toolbar = UIToolbar()
            toolbar.barStyle = .default
            toolbar.isTranslucent = true
            toolbar.sizeToFit()
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.datePickerDone))
            toolbar.setItems([doneButton], animated: false)
            toolbar.isUserInteractionEnabled = true
            
            // Assign the date picker to be the input view of the textfield
            textField.inputAccessoryView = toolbar
            textField.inputView = datePicker
            textField.text = formatDateForDisplay(date: datePicker.date)
        }
    }
    
    @objc func updateTextInField(sender: UIDatePicker) {
        self.dateTextField.text = formatDateForDisplay(date: sender.date)
    }
    
    // ---- Date Formatting ---- //
    
    fileprivate func formatDateForDisplay(date: Date?) -> String {
        if let d = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            return formatter.string(from: d)
        }
        return ""
    }
    
    fileprivate func stringToDate(dateString: String?) -> Date? {
        if let dateStr = dateString {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            return formatter.date(from: dateStr)
        }
        return nil
    }
    
    @objc func datePickerDone() {
        dateTextField.resignFirstResponder()
    }

}
