//
//  CategoryFooterCell.swift
//  Envelopes-HU
//
//  Created by Jeremy Campbell on 4/20/19.
//  Copyright © 2019 Jeremy Campbell. All rights reserved.
//

import UIKit

class CategoryFooterCell: UITableViewCell {

    var delegate: CategoryFooterCellDelegate?
    var categoryName: String!
    var sectionNumber: Int!
    
    @IBAction func deleteCategory(_ sender: UIButton) {
        // Notify delegate that the delete button has been pressed
        if let d = delegate {
            d.categoryFooterCell(self)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

protocol CategoryFooterCellDelegate {
    func categoryFooterCell(_ categoryFooterCell: CategoryFooterCell)
}
