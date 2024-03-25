//
//  CredentialItemView.swift
//  eBalo
//
//  Created by Ivan Lele on 22.03.2024.
//

import SwiftUI

struct CredentialItemView: View {
    let credential: Credential
    
    let dateFormatter: DateFormatter
    
    init(_ credential: Credential) {
        self.credential = credential
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .gmt
        dateFormatter.dateFormat = "MM/dd"
        
        self.dateFormatter = dateFormatter
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [.grad2, .grad1],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            VStack {
                Spacer()
                HStack {
                    Image("DotFlagIcon")
                        .rotationEffect(.degrees(180))
                    Spacer()
                }
            }
            .padding()
            VStack {
                HStack {
                    Text(dateFormatter.string(from: credential.createdAt))
                        .foregroundStyle(.lightGrey)
                    Spacer()
                    ZStack {
                        Circle()
                            .foregroundStyle(.lightGrey)
                            .opacity(0.5)
                        Image("BlackPepper")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .frame(width: 40, height: 40)
                }
                .padding()
                Spacer()
                HStack {
                    Spacer()
                    Text("Proof of human identity")
                        .font(.customFont(font: .helvetica, style: .bold, size: 14))
                        .foregroundStyle(.white)
                }
                .padding()
            }
        }
        .frame(width: 327.33, height: 174)
    }
}

#Preview {
    CredentialItemView(Credential.sample)
}
