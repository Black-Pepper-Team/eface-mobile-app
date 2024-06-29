//
//  MainTabView.swift
//  eBalo
//
//  Created by Ivan Lele on 22.03.2024.
//

import SwiftUI

struct MainTabView: View {
    @Binding var activeTab: Int
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 100)
                .foregroundStyle(.dullBlue)
            HStack {
                MainTabItemView(
                    activeTab: $activeTab,
                    iconName: "CardIcon",
                    tag: 0
                )
                MainTabItemView(
                    activeTab: $activeTab,
                    iconName: "PersonIcon",
                    tag: 1
                )
                MainTabItemView(
                    activeTab: $activeTab,
                    iconName: "InfoIcon",
                    tag: 2
                )
                MainTabItemView(
                    activeTab: $activeTab,
                    iconName: "SettingsView",
                    tag: 3
                )
            }
        }
        .frame(width: 225, height: 56)
    }
}

struct MainTabItemView: View {
    @Binding var activeTab: Int
    
    let iconName: String
    let tag: Int
    
    var body: some View {
        Button(action: {
            self.activeTab = tag
        }) {
            ZStack {
                Circle()
                    .foregroundStyle(
                        self.activeTab == tag
                        ? .lightGrey
                        : .dullBlue
                    )
                Image(iconName)
                    .renderingMode(.template)
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 48, height: 48)
    }
}

#Preview {
    MainTabView(activeTab: .constant(0))
        .environmentObject(MainView.ViewModel())
}
