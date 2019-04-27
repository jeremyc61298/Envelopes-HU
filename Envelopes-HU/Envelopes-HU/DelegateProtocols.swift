//
//  DelegateProtocols.swift
//  Envelopes-HU
//
//  Created by Jeremy Campbell on 4/22/19.
//  Copyright © 2019 Jeremy Campbell. All rights reserved.
//

protocol ModalViewDelegate {
    func modalDismissed()
}

protocol TransactionHeaderCellDelegate {
    func clearAllTransactions()
}
