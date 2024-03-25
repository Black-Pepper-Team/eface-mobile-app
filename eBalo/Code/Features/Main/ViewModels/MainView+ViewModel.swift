//
//  MainView+ViewModel.swift
//  eBalo
//
//  Created by Ivan Lele on 22.03.2024.
//

import Foundation

extension MainView {
    class ViewModel: ObservableObject {
        @Published var activeTab = 0
    }
}
