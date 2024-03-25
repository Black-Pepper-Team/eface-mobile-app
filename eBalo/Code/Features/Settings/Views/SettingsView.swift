//
//  SettingsView.swift
//  eBalo
//
//  Created by Ivan Lele on 22.03.2024.
//

import SwiftUI
import Web3

struct SettingsView: View {
    @EnvironmentObject private var appViewModel: AppView.ViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("Settings")
                    .font(.customFont(font: .helvetica, style: .bold, size: 20))
                    .foregroundStyle(.dullBlue)
                Spacer()
            }
            .padding(.horizontal)
            ZStack {}
                .frame(height: 30)
            if appViewModel.secretKey != nil {
                SettingsEntryView("TrashIcon", "Delete Keys") {
                    SimpleStorage.eraceSecretKey()
                    appViewModel.secretKey = nil
                    appViewModel.fetchHistoryCancelable?.cancel()
                    appViewModel.fetchHistoryCancelable = nil
                    appViewModel.historyEntries = []
                }
            } else {
                SettingsImportKeysView()
            }
            if !appViewModel.credentials.isEmpty {
                SettingsEntryView("TrashIcon", "Delete Credentials") {
                    appViewModel.eraceCreds()
                }
            }
            Spacer()
        }
    }
}

struct SettingsImportKeysView: View {
    @EnvironmentObject private var appViewModel: AppView.ViewModel
    
    @State private var isImporting = false
    @State private var newPrivateKey = ""
    
    var body: some View {
        VStack {
            if isImporting {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(.white)
                    HStack {
                        TextField("Enter private key", text: $newPrivateKey)
                        Spacer()
                        Button(action: {
                            guard let secreKeyFul = try? EthereumPrivateKey(hexPrivateKey: newPrivateKey) else {
                                return
                            }
                            
                            SimpleStorage.saveSecretKey(newPrivateKey)
                            appViewModel.secretKey = newPrivateKey
                            appViewModel.historyEntries = []
                            appViewModel.fetchHistory()
                            newPrivateKey = ""
                            isImporting = false
                            
                        }) {
                            ZStack {
                                Circle()
                                    .foregroundStyle(.dullBlue)
                                    .frame(width: 32, height: 32)
                                Image(systemName: "arrow.forward")
                                    .foregroundStyle(.white)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                }
                .frame(width: 366, height: 64)
            } else {
                SettingsEntryView("KeyIcon", "Import Keys") {
                    isImporting = true
                }
            }
        }
    }
}

struct SettingsEntryView: View {
    let iconName: String
    let text: String
    
    let onClick: () -> Void
    
    init(_ iconName: String, _ text: String, _ onClick: @escaping () -> Void) {
        self.iconName = iconName
        self.text = text
        self.onClick = onClick
    }
    
    var body: some View {
        Button(action: onClick) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(.white)
                HStack {
                    ZStack {
                        Circle()
                            .frame(width: 32, height: 32)
                            .foregroundStyle(.dullBlue)
                        Image(iconName)
                            .renderingMode(.template)
                            .foregroundStyle(.white)
                    }
                    Text(text)
                        .font(.customFont(font: .helvetica, style: .bold, size: 14))
                        .foregroundStyle(.dullBlue)
                        .padding(.leading)
                    Spacer()
                    Image(systemName: "arrow.forward")
                }
                .padding()
            }
        }
        .frame(width: 366, height: 64)
    }
}

#Preview {
    VStack {
        SettingsView()
    }
    .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    .background(Color(.systemGroupedBackground))
    .environmentObject(AppView.ViewModel())
}
