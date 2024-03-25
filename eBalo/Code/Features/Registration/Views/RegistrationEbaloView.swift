//
//  RegistrationEbaloView.swift
//  eBalo
//
//  Created by Ivan Lele on 23.03.2024.
//

import SwiftUI

struct RegistrationEbaloView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel
    
    @ObservedObject var registrationStatus: RegistrationStatus
    
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State var image: UIImage?
    
    @State var nickName = ""
    
    @State var isRequesting = false
    
    @State var isError = false
    
    var body: some View {
        VStack {
            HStack {
                Text("eBalo Registration")
                    .font(.customFont(font: .helvetica, style: .bold, size: 20))
                    .foregroundStyle(.dullBlue)
                Spacer()
                Button(action: {
                    registrationStatus.isFacePassing = false
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
            if let selectedImage {
                Spacer()
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(15)
                    .frame(width: 350)
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
                                    let claimId = try await self.appViewModel.testDima(
                                        selectedImage,
                                        registrationStatus,
                                        nickName
                                    )
                                    
                                    registrationStatus.faceClaimId = claimId
                                    
                                    print("ebalo claim id: \(claimId)")
                                    
                                    registrationStatus.isFacePassed = true
                                    registrationStatus.isFacePassing = false
                                } catch let error {
                                    if "\(error)".contains("ERRWRONGEBALO") {
                                        isError = true
                                    }
                                    
                                    print(error)
                                }
                            }
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .foregroundStyle(.dullBlue)
                                Text("Register your eBalo")
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
            } else {
                VStack {
                    LottieView(animationFileName: "FaceScan", loopMode: .loop)
                        .frame(width: 250, height: 300)
                    ZStack {}
                        .frame(width: 30)
                    Text("We generate your identity based on the provided face biometrics using advanced AI algorithm")
                        .font(.customFont(font: .helvetica, style: .regular, size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.lightGrey)
                        .frame(width: 300)
                    Spacer()
                    CommonButtonView("Select preimage for your eBalo") {
                        self.showCamera.toggle()
                    }
                    .fullScreenCover(isPresented: self.$showCamera) {
                        accessCameraView(selectedImage: self.$selectedImage)
                            .ignoresSafeArea()
                    }
                }
            }
            }
        }
        .alert("Failed to detect salt in speech try again", isPresented: $isError) {
            Button("OK", role: .cancel) {
                selectedImage = nil
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    RegistrationEbaloView(registrationStatus: RegistrationStatus())
        .environmentObject(AppView.ViewModel())
}
