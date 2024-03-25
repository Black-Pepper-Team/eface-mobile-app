//
//  EbaloView.swift
//  eBalo
//
//  Created by Ivan Lele on 22.03.2024.
//

import SwiftUI
import PhotosUI
import Web3
import Alamofire
import Identity

struct EbaloView: View {
    @EnvironmentObject private var appViewModel: AppView.ViewModel
    
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State var image: UIImage?
    @State private var amount: Int? = nil
    
    @State var isRequesting = false
    
    @State var nickname: String = ""
    @State var pubkey: String = ""
    @State var userId: String = ""
    @State var sendingAddress: String = ""
    
    @State var isError = false
    
    var body: some View {
        VStack {
            HStack {
                Text("eBalo Transfer")
                    .font(.customFont(font: .helvetica, style: .bold, size: 20))
                    .foregroundStyle(.dullBlue)
                Spacer()
                if appViewModel.secretKey != nil {
                    EbaloBalanceView()
                }
            }
            .padding()
            Spacer()
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(15)
                    .onAppear {
                        isRequesting = true
                        
                        Task { @MainActor in
                            defer {
                                isRequesting = false
                            }
                            
                            do {
                                let resp = try await appViewModel.getEbalo(selectedImage)
                                
                                nickname = resp.metadata
                                pubkey = resp.publicKey
                                userId = resp.userId
                            } catch let error {
                                if "\(error)".contains("ERROREBALONOTFOUND") {
                                    isError = true
                                }
                                
                                print(error)
                            }
                        }
                    }
                    .onDisappear {
                        isRequesting = true
                    }
                if !nickname.isEmpty {
                    Text(nickname)
                        .font(.customFont(font: .helvetica, style: .bold, size: 20))
                        .foregroundStyle(.dullBlue)
                }
                
                if isRequesting {
                    ProgressView()
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundStyle(.white)
                        HStack {
                            TextField("Amount", value: $amount, format: .number)
                                .keyboardType(.decimalPad)
                            Spacer()
                            Button(action: {
                                isRequesting = true
                                
                                Task { @MainActor in
                                    defer {
                                        isRequesting = false
                                        self.selectedImage = nil
                                    }
                                    do {
                                        let localUserid = SimpleStorage.loadUserId()!
                                        
                                        let from = try await appViewModel.getAddressByUserId(localUserid)
                                        
                                        print(from)
                                        
                                        let identity = IdentityNewIdentity(
                                            appViewModel.secretKey!,
                                            nil,
                                            nil
                                        )!
                                        
                                        let tx_hash = try await appViewModel.transfer(
                                            identity,
                                            token: "0xb2827acFc8A1bC44c4B73897Fb765EEd95719d4c",
                                            amount: amount ?? 0,
                                            to: sendingAddress,
                                            contract: from
                                        )
                                        
                                        print(tx_hash)
                                    } catch let error {
                                        print(error)
                                    }
                                }
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .foregroundStyle(.dullBlue)
                                    Text("Transfer to this eBalo")
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
                }
            } else {
                Button(action: {
                    self.showCamera.toggle()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundStyle(.dullBlue)
                        Text("Selected eBalo to Transfer")
                            .font(.customFont(font: .helvetica, style: .bold, size: 14))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 200, height: 35)
                }
                .disabled(SimpleStorage.loadUserId() == nil)
                .fullScreenCover(isPresented: self.$showCamera) {
                    accessCameraView(selectedImage: self.$selectedImage)
                        .ignoresSafeArea()
                }
            }
            Spacer()
            if !appViewModel.historyEntries.isEmpty {
                EbaloHistoryView()
                    .frame(height: 400)
            }
        }
        .onChange(of: userId) { changed in
            if !userId.isEmpty {
                isRequesting = true
                
                Task { @MainActor in
                    defer {
                        isRequesting = false
                    }
                    do {
                        print(userId)
                        
                        sendingAddress = try await appViewModel.getAddressByUserId(userId)
                        
                        print(sendingAddress)
                    } catch let error {
                        print(error)
                    }
                }
            }
        }
        .alert("eBalo wasn't found", isPresented: $isError) {
            Button("OK", role: .cancel) {
                selectedImage = nil
                
                nickname = ""
                pubkey = ""
                userId = ""
                sendingAddress = ""
            }
        }
        .padding(.horizontal)
    }
}

struct EbaloBalanceView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel
    
    var body: some View {
        Button(action: {
            appViewModel.fetchBalance()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(.dullBlue)
                HStack {
                    Text("\(appViewModel.balance)")
                        .font(.customFont(font: .helvetica, style: .bold, size: 14))
                        .foregroundStyle(.white)
                    Spacer()
                    Image("BlackPepper")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(.white)
                        .frame(width: 20, height: 20)
                }
                .padding(.horizontal)
            }
        }
        .frame(width: 100, height: 25)
    }
}

struct accessCameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var isPresented
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = context.coordinator
        imagePicker.cameraDevice = .front
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self)
    }
}

// Coordinator will help to preview the selected image in the View.
class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: accessCameraView
    
    init(picker: accessCameraView) {
        self.picker = picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        self.picker.selectedImage = selectedImage
        self.picker.isPresented.wrappedValue.dismiss()
    }
}

#Preview {
    VStack {
        EbaloView()
    }
    .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    .background(Color(.systemGroupedBackground))
    .environmentObject(AppView.ViewModel())
}
