//
//  CategoryHeaderCell.swift
//  Envelopes-HU
//
//  Created by Jeremy Campbell on 4/20/19.
//  Copyright © 2019 Jeremy Campbell. All rights reserved.
//

import UIKit

class CategoryHeaderCell: UITableViewCell {
   
    // Need the title of the category and a button to add an envelope in that category
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var addEnvelope: AddEnvelopeButton!
    var sectionNumber: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class AddEnvelopeButton: UIButton {
    var sectionNumber: Int!
}
