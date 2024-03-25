//
//  RegistrationView.swift
//  eBalo
//
//  Created by Ivan Lele on 23.03.2024.
//

import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel
    
    @ObservedObject var registrationStatus: RegistrationStatus
    
    @State var isRecording = false
    
    @State var isError = false
    
    var body: some View {
        VStack {
            if registrationStatus.isFacePassing {
                RegistrationEbaloView(registrationStatus: registrationStatus)
            } else if registrationStatus.isVoicePassing {
                RegistrationVoiceView(registrationStatus: registrationStatus)
            } else if registrationStatus.isPassPassing {
                RegistrationPassportView(registrationStatus: registrationStatus)
            } else {
                HStack {
                    Text("Registration")
                        .font(.customFont(font: .helvetica, style: .bold, size: 20))
                        .foregroundStyle(.dullBlue)
                    Spacer()
                    Button(action: {
                        self.registrationStatus.clean()
                    }) {
                        ZStack {
                            Circle()
                                .foregroundStyle(.dullBlue)
                            Image(systemName: "xmark")
                                .foregroundStyle(.white)
                            
                        }
                        .frame(width: 50, height: 50)
                    }
                }
                .padding()
                if !isRecording {
                    RegistrationRequirementsView(
                        registrationStatus: registrationStatus,
                        onPass: {
                            registrationStatus.isPassPassing = true
                        },
                        onPhoto: {
                            registrationStatus.isFacePassing = true
                        },
                        onVoice: {
                            registrationStatus.isVoicePassing = true
                        }
                    )
                    Spacer()
                    //                if registrationStatus.isPassPassed && registrationStatus.isFacePassed && registrationStatus.isVoicePassed {
                                        CommonButtonView("Register") {
                                            isRecording = true
//                                            
                                            Task { @MainActor in
                                                do {
                                                    defer {
                                                        self.isRecording = false
                                                    }
                                                    
                                                    let tx_hash = try await appViewModel.registerUser(registrationStatus)
                                                    
                                                    print(tx_hash)
                                                    
                                                    appViewModel.createCred(registrationStatus.identity.usedId)
                                                    
                                                    registrationStatus.clean()
                                                } catch let error {
                                                    if "\(error)".contains("Account already registered") {
                                                        appViewModel.createCred(registrationStatus.identity.usedId)
                                                        
                                                        print("Account already registered")
                                                        
                                                        registrationStatus.clean()
                                                        
                                                        return
                                                    }
                                                    
                                                    isError = true
                                                    print(error)
                                                }
                                            }
                                        }
                    //                }
                } else {
                    VStack {
                        Spacer()
                        ProgressView()
                            .controlSize(.large)
                        Spacer()
                    }
                }

            }
        }
        .alert("Got error, ask Dima", isPresented: $isError) {
            Button("OK", role: .cancel) {
                registrationStatus.clean()
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct RegistrationRequirementsView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel
    
    @ObservedObject var registrationStatus: RegistrationStatus
    
    let onPass: () -> Void
    let onPhoto: () -> Void
    let onVoice: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(.white)
            VStack {
                HStack {
                    Text("Requirements")
                        .font(.customFont(font: .helvetica, style: .bold, size: 16))
                        .foregroundStyle(.dullBlue)
                    Spacer()
                }
                .padding()
                List {
                    Button(action: {
                        if !registrationStatus.isPassPassed {
                            onPass()
                        }
                    }) {
                        RegistrationRequirementView(
                            icon: "CardIcon",
                            title: "Passport",
                            subTitle: "Proof your identity by ePassport",
                            isRevoced: self.$registrationStatus.isPassRevoced,
                            isPassed: self.$registrationStatus.isPassPassed
                        )
                    }
                    .buttonStyle(.plain)
                    Button(action: {
                        if !registrationStatus.isFacePassed {
                            onPhoto()
                        }
                    }) {
                        RegistrationRequirementView(
                            icon: "PersonIcon",
                            title: "Face",
                            subTitle: "Proof your identity by eBalo",
                            isRevoced: self.$registrationStatus.isFaceRevoced,
                            isPassed: self.$registrationStatus.isFacePassed
                        )
                    }
                    .buttonStyle(.plain)
                    Button(action: {
                        if !registrationStatus.isVoicePassed {
                            onVoice()
                        }
                    }) {
                        RegistrationRequirementView(
                            icon: "VoiceIcon",
                            title: "Voice",
                            subTitle: "Proof your identity by hleBalo",
                            isRevoced: self.$registrationStatus.isVoiceRevoced,
                            isPassed: self.$registrationStatus.isVoicePassed
                        )
                    }
                    .buttonStyle(.plain)
                }
                .scrollContentBackground(.hidden)
                .background(.clear)
                .listStyle(.plain)
                Spacer()
            }
        }
        .frame(width: 366, height: 264)
    }
}

struct RegistrationRequirementView: View {
    let icon: String
    let title: String
    let subTitle: String
    @Binding var isRevoced: Bool
    
    @Binding var isPassed: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16).foregroundStyle(.white)
            HStack {
                ZStack {
                    Circle()
                        .foregroundStyle(.dullBlue)
                        .frame(width: 40, height: 40)
                    Image(icon)
                        .renderingMode(.template)
                        .foregroundStyle(.white)
                }
                VStack {
                    HStack {
                        Text(title)
                            .font(.customFont(font: .helvetica, style: .bold, size: 14))
                            .foregroundStyle(.dullBlue)
                        Spacer()
                    }
                    ZStack {}
                        .frame(height: 1)
                    HStack {
                        Text(subTitle)
                            .font(.customFont(font: .helvetica, style: .regular, size: 12))
                            .foregroundStyle(.lightGrey)
                        Spacer()
                    }
                }
                .padding(.leading)
                Spacer()
                if isRevoced {
                    Image(systemName: "arrow.3.trianglepath")
                        .foregroundStyle(.green)
                }
                if isPassed {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.dullBlue)
                } else {
                    Image(systemName: "arrow.forward")
                        .foregroundStyle(.dullBlue)
                }
            }
        }
    }
}

#Preview {
    RegistrationView(registrationStatus: RegistrationStatus())
        .environmentObject(AppView.ViewModel())
}
