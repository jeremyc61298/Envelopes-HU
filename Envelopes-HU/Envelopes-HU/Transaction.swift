//
//  Transaction.swift
//  Envelopes-HU
//
//  Created by Jeremy Campbell on 4/12/19.
//  Copyright © 2019 Jeremy Campbell. All rights reserved.
//

import Foundation

class Transaction {
    var title: String
    var amount: Double
    var isExpense: Bool
    var date: Date
    var note: String?
    
    init(title: String, amount: Double, isExpense: Bool, date: Date, note: String?) {
        self.title = title
        self.amount = amount
        self.isExpense = isExpense
        self.date = date
        self.note = note
    }
}
