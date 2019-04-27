//
//  TransactionHeaderCell.swift
//  Envelopes-HU
//
//  Created by Jeremy Campbell on 4/26/19.
//  Copyright © 2019 Jeremy Campbell. All rights reserved.
//

import UIKit

class TransactionHeaderCell: UITableViewCell {

    var delegate: TransactionHeaderCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Great place for a delegate
    @IBAction func clearAllTransactions(_ sender: UIButton) {
        if (delegate != nil) {
            delegate!.clearAllTransactions()
        }
    }
    
}
