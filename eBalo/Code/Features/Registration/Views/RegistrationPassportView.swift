//
//  RegistrationPassportView.swift
//  eBalo
//
//  Created by Ivan Lele on 23.03.2024.
//

import SwiftUI
import Alamofire

struct RegistrationPassportView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel
    
    @ObservedObject var registrationStatus: RegistrationStatus
    
    @StateObject var nfcController = NFCScannerController()
    @StateObject var mrzController = MRZScannerController()
    
    @State var isRequesting = false
    @State var isMRZ = false
    @State var isNFT = false
    @State var isNickname = false
    
    @State var nickName = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("ePassport Registration")
                    .font(.customFont(font: .helvetica, style: .bold, size: 20))
                    .foregroundStyle(.dullBlue)
                Spacer()
                Button(action: {
                    registrationStatus.isPassPassing = false
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
            if isRequesting {
                Spacer()
                ProgressView()
                    .controlSize(.large)
                Spacer()
            } else {
                if isNickname {
                    Spacer()
                    Image(uiImage: nfcController.nfcModel!.passportImage!)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(15)
                        .frame(width: 200)
                        Text("\(nfcController.nfcModel!.firstName.capitalized) \(nfcController.nfcModel!.lastName.capitalized)")
                        .font(.customFont(font: .helvetica, style: .bold, size: 20))
                        .foregroundStyle(.dullBlue)
                        .padding(.top)
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundStyle(.white)
                        HStack {
                            TextField("Nickname", text: $nickName)
                            Spacer()
                            Button(action: {
                                isRequesting = true
                                
                                Task { @MainActor in
                                    defer {
                                        isRequesting = false
                                    }
                                    do {
                                        let claimId = try await self.appViewModel.testAnton(
                                            nfcController.nfcModel!,
                                            registrationStatus,
                                            nickName
                                        )
                                        
                                        if claimId == "" {
                                            return
                                        }
                                        
                                        registrationStatus.passClaimId = claimId
                                        
                                        print("passport claim id: \(claimId)")
                                        
                                        registrationStatus.isPassPassed = true
                                        registrationStatus.isPassPassing = false
                                    } catch let error {
                                        print(error)
                                    }
                                }
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .foregroundStyle(.dullBlue)
                                    Text("Register your ePassport")
                                        .font(.customFont(font: .helvetica, style: .bold, size: 14))
                                        .foregroundStyle(.white)
                                        .disabled(appViewModel.secretKey == nil)
                                }
                            }
                            .frame(width: 200, height: 35)
                        }
                        .padding(.leading)
                    }
                    .frame(width: 350, height: 42)
                } else if !isMRZ {
                    Spacer()
                    Image("PasspordIcon")
                        .resizable()
                        .frame(width: 250, height: 250)
                    ZStack {}
                        .frame(height: 20)
                    Text("We generate your identity based on the provided passport biometric")
                        .font(.customFont(font: .helvetica, style: .regular, size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.lightGrey)
                        .frame(width: 300)
                    Spacer()
                    CommonButtonView("Select preimage for your ePassport") {
                        isMRZ = true
                    }
                } else if isMRZ && isNFT {
                    Spacer()
                    LottieView(animationFileName: "passNFC", loopMode: .loop)
                        .frame(width: 300, height: 300)
                        .padding(.bottom)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                nfcController.read(mrzController.mrzKey)
                            }
                        }
                    Text("Put your phone on NFC and scan")
                        .font(.customFont(font: .helvetica, style: .regular, size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.lightGrey)
                        .frame(width: 300)
                    Spacer()
                } else if isMRZ {
                    ZStack {}
                        .frame(width: 100)
                    RegistrationMRZView(mrzController: mrzController)
                        .onAppear {
                            mrzController.startScanning()
                        }
                    Text("Scan your document fist page")
                        .font(.customFont(font: .helvetica, style: .regular, size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.lightGrey)
                        .frame(width: 300)
                    Spacer()
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            mrzController.setOnScanned {
                isMRZ = true
                isNFT = true
            }
            
            nfcController.setOnScanned {
                isNickname = true
            }
            
            nfcController.setOnError {
                isNFT = true
            }
        }
    }
}

struct RegistrationMRZView: View {
    @ObservedObject var mrzController: MRZScannerController
    
    var body: some View {
        VStack {
            ZStack {
                MRZScannerView(mrtScannerController: mrzController)
                    .mask {
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: 370, height: 270)
                    }
            }
            .frame(height: 320)
        }
    }
}

#Preview {
    RegistrationPassportView(registrationStatus: RegistrationStatus())
        .environmentObject(AppView.ViewModel())
}
