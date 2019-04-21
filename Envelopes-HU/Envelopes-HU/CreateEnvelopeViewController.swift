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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        envelopeName.delegate = self
        envelopeAmount.delegate = self
    }
    
    @IBAction func cancelCreation(_ sender: UIBarButtonItem) {
        // Go back to the main nav controller
        dismiss(animated: true, completion: nil)
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
