//
//  CreateEnvelopeViewController.swift
//  Envelopes-HU
//
//  Created by Jeremy Campbell on 4/20/19.
//  Copyright © 2019 Jeremy Campbell. All rights reserved.
//

import UIKit

class CreateEnvelopeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var envelopeName: UITextField!
    @IBOutlet weak var envelopeAmount: UITextField!
    var section: Int!
    var delegate: ModalViewDelegate!
    let envelopesController = EnvelopesController.getInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UITextField Delegation
        envelopeName.delegate = self
        envelopeAmount.delegate = self
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
    
    @IBAction func createEnvelope(_ sender: UIBarButtonItem) {
        let title = envelopeName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let amount = envelopeAmount.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if let errMsg = envelopesController.addEnvelope(toSection: section, withTitle: title, withAmount: Double(amount)) {
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
    
    // UITextFieldDelegate
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
