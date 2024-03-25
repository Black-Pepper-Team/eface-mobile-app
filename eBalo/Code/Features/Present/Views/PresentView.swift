//
//  PresentView.swift
//  eBalo
//
//  Created by Ivan Lele on 23.03.2024.
//

import SwiftUI
import CodeScanner
import Alamofire

struct PresentView: View {
    @State var isErrorUseID = false
    
    @State var isAm = false
    @State var Am = ""
    
    @State var isLoading = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Rewarder")
                        .font(.customFont(font: .helvetica, style: .bold, size: 20))
                        .foregroundStyle(.dullBlue)
                    Spacer()
                }
                .padding(.horizontal)
                Spacer()
                ZStack {
                    CodeScannerView(codeTypes: [.qr], videoCaptureDevice: .bestForVideo) { response in
                        guard let userId = SimpleStorage.loadUserId() else {
                            isErrorUseID = true
                            return
                        }
                        
                        isLoading = true
                        
                        Task { @MainActor in
                            defer {
                                isLoading = false
                            }
                            
                            do {
                                var url = try response.get().string
                                url += userId
                                
                                let response = try await AF.request(url)
                                    .serializingDecodable(PresentResponse.self)
                                    .result
                                    .get()
                                
                                Am = response.EBT
                                isAm = true
                            } catch let error {
                                print(error)
                            }
                        }
                    }
                    .frame(width: 200, height: 200)
                    if isLoading {
                        ProgressView()
                            .controlSize(.large)
                            
                    } else {
                        LottieView(animationFileName: "qr", loopMode: .loop)
                    }
                }
                Spacer()
            }
            
            Text("Scan QR code to get your reward")
                .font(.customFont(font: .helvetica, style: .regular, size: 16))
                .foregroundStyle(.lightGrey)
                .offset(y: 200)
        }
        .alert("You does not have identity", isPresented: $isErrorUseID) {
            Button("OK", role: .cancel) {}
        }
        
        .alert("You got \(Am) EBM tokens", isPresented: $isAm) {
            Button("OK", role: .cancel) {}
        }
    }
}

#Preview {
    PresentView()
}
