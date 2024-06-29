//
//  CredentialsView.swift
//  eBalo
//
//  Created by Ivan Lele on 22.03.2024.
//

import SwiftUI

struct CredentialsView: View {
    @EnvironmentObject private var appViewModel: AppView.ViewModel
    
    let onCreate: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Text("Credentials")
                    .font(.customFont(font: .helvetica, style: .bold, size: 20))
                    .foregroundStyle(.dullBlue)
                Spacer()
                NavigationLink {
                    ContactsView()
                        .navigationBarBackButtonHidden()
                } label: {
                    ZStack {
                        Circle()
                            .foregroundStyle(.lightGrey)
                        Image(systemName: "book.closed.fill")
                            .foregroundStyle(.dullBlue)
                    }
                    .frame(width: 30, height: 30)
                }
            }
            .padding(.horizontal)
            HStack {
                Text("\(appViewModel.credentials.count) Active")
                    .font(.customFont(font: .helvetica, style: .regular, size: 12))
                    .foregroundStyle(.lightGrey)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom)
            if appViewModel.credentials.isEmpty {
                List {
                    HStack {
                        Spacer()
                        CredentialsEmptyView {
                            onCreate()
                        }
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
                .background(.clear)
                .listStyle(.plain)
            } else {
                ForEach(appViewModel.credentials, id: \.id) { cred in
                    List {
                        HStack {
                            Spacer()
                            CredentialItemView(cred)
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .scrollContentBackground(.hidden)
                    .background(.clear)
                    .listStyle(.plain)
                }
            }
            Spacer()
        }
    }
}

struct CredentialsEmptyView: View {
    @EnvironmentObject private var appViewModel: AppView.ViewModel
    let onCreate: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(.white)
                .shadow(radius: 1, y: 1)
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(.white)
                .frame(width: 326, height: 196)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.lightGrey, lineWidth: 1)
                        .opacity(0.1)
                )
            VStack {
                ZStack {
                    Circle()
                        .foregroundStyle(.dullBlue)
                    Image("CardIcon")
                        .renderingMode(.template)
                        .foregroundStyle(.white)
                }
                .frame(width: 48, height: 48)
                Text("No Credentials")
                    .font(.customFont(font: .helvetica, style: .regular, size: 16))
                    .foregroundStyle(.dullBlue)
                    .padding(.top)
                Button(action: {
                    onCreate()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 100)
                            .foregroundStyle(.dullBlue)
                        Text("New")
                            .font(.customFont(font: .helvetica, style: .bold, size: 16))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)
                .frame(width: 77, height: 32)
                .padding(.top)
                .disabled(appViewModel.secretKey == nil)
            }
        }
        .frame(width: 366, height: 236)
    }
}

#Preview {
    VStack {
        CredentialsView() {}
    }
    .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    .background(Color(.systemGroupedBackground))
    .environmentObject(AppView.ViewModel())
}
