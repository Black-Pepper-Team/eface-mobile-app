//
//  EbaloHistoryView.swift
//  eBalo
//
//  Created by Ivan Lele on 23.03.2024.
//

import SwiftUI
import PhotosUI

struct EbaloHistoryView: View {
    @EnvironmentObject private var appViewModel: AppView.ViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("History")
                    .font(.customFont(font: .helvetica, style: .bold, size: 16))
                    .foregroundStyle(.dullBlue)
                Spacer()
                Button(action: {
                    appViewModel.fetchHistory()
                }) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .foregroundStyle(.dullBlue)
                }
                .buttonStyle(.plain)
            }
            .padding()
            List {
                ForEach(appViewModel.historyEntries, id: \.txId) { entry in
                    EbaloHistoryEntryView(entry)
                }
            }
            .padding(.bottom)
        }
    }
}

struct EbaloHistoryEntryView: View {
    let entry: EbaloHistoryEntry
    
    let dateFormatter: DateFormatter
    
    init(_ entry: EbaloHistoryEntry) {
        self.entry = entry
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        self.dateFormatter = dateFormatter
    }
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .foregroundStyle(.dullBlue)
                    .frame(width: 40, height: 40)
                Image(systemName: "calendar")
                    .foregroundStyle(.white)
            }
            VStack {
                HStack {
                    Text(entry.isReceiving ? "Received" : "Sended")
                        .font(.customFont(font: .helvetica, style: .bold, size: 14))
                        .foregroundStyle(.dullBlue)
                    Spacer()
                }
                ZStack {}
                    .frame(height: 1)
                HStack {
                    Text(dateFormatter.string(from: entry.at))
                        .font(.customFont(font: .helvetica, style: .regular, size: 12))
                        .foregroundStyle(.lightGrey)
                    Spacer()
                }
            }
            .padding(.leading)
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 48)
                    .foregroundStyle(.dullBlue)
                HStack {
                    Text(entry.isReceiving ? "+\(entry.value.description)" : "-\(entry.value.description)")
                        .font(.customFont(font: .helvetica, style: .bold, size: 12))
                        .foregroundStyle(.white)
                    Image("BlackPepper")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(.white)
                        .frame(width: 16, height: 16)
                }
                .frame(width: 55, height: 20)
            }
            .frame(width: 58, height: 20)
        }
    }
}

#Preview {
    EbaloHistoryView()
        .environmentObject(AppView.ViewModel())
}
