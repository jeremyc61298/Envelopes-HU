//
//  Envelope.swift
//  Envelopes-HU
//
//  Created by Jeremy Campbell on 4/12/19.
//  Copyright © 2019 Jeremy Campbell. All rights reserved.
//

import Foundation

class Envelope {
    var title: String
    var about: String?
    var totalAmount: Double
    var transactions: [Transaction] = []
    
    init(_ title: String, _ total: Double) {
        self.title = title
        self.totalAmount = total
    }
}
