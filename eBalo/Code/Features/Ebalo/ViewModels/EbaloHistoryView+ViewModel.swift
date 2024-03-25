//
//  EbaloHistoryView+ViewModel.swift
//  eBalo
//
//  Created by Ivan Lele on 23.03.2024.
//

import Foundation

extension EbaloHistoryView {
    class ViewModel: ObservableObject {
        let privateKey: String?
        
        @Published var entries: [EbaloHistoryEntry] = []
        
        init(_ privateKey: String?) {
            self.privateKey = privateKey
        }
    }
}
