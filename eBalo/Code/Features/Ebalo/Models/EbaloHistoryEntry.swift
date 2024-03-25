//
//  EbaloHistory.swift
//  eBalo
//
//  Created by Ivan Lele on 23.03.2024.
//

import Foundation
import Web3

struct EbaloHistoryEntry {
    let txId: String
    let at: Date
    let value: Int
    let isReceiving: Bool
}

extension EbaloHistoryEntry {
    static let sample: [Self] = [
        Self(
            txId: "32131",
            at: Date(),
            value: 34,
            isReceiving: false
        ),
        Self(
            txId: "5433",
            at: Date(),
            value: 74,
            isReceiving: true
        ),
    ]
}
