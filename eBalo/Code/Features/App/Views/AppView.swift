//
//  EntryView.swift
//  eBalo
//
//  Created by Ivan Lele on 18.03.2024.
//

import SwiftUI

struct AppView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isIntroPassed {
                MainView()
            } else {
                IntroView(isPassed: $viewModel.isIntroPassed)
            }
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    AppView()
}
