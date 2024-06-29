//
//  MainView.swift
//  eBalo
//
//  Created by Ivan Lele on 21.03.2024.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var appViewModel: AppView.ViewModel
    @StateObject var registrationStatus = RegistrationStatus()
    
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    if registrationStatus.isCreatingNew {
                        RegistrationView(registrationStatus: registrationStatus)
                    } else {
                        if viewModel.activeTab == 0 {
                            CredentialsView() {
                                self.registrationStatus.start()
                            }
                        }
                        if viewModel.activeTab == 1 {
                            EbaloView()
                        }
                        if viewModel.activeTab == 2 {
                            CommunitiesView()
                        }
                        if viewModel.activeTab == 3 {
                            SettingsView()
                        }
                        Spacer()
                        ZStack {
                            MainTabView(activeTab: $viewModel.activeTab)
                            HStack {
                                Spacer()
                                NavigationLink {
                                    ELeleChatView()
                                        .navigationBarBackButtonHidden(true)
                                } label: {
                                    ELeleAssistentButton()
                                        .padding()
                                }
                            }
                        }
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .environmentObject(ViewModel())
        .onAppear {
            appViewModel.fetchHistory()
            appViewModel.fetchBalance()
        }
        .onAppear {
            print("usedId: \(SimpleStorage.loadUserId() ?? "")")
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AppView.ViewModel())
}
