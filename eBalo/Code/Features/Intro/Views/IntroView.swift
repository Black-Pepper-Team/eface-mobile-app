//
//  IntroView.swift
//  eBalo
//
//  Created by Ivan Lele on 22.03.2024.
//

import SwiftUI

struct IntroView: View {
    @Binding var isPassed: Bool
    
    var body: some View {
        VStack {
            Spacer()
            Image("BlackPepper")
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(.dullBlue)
                .frame(width: 200, height: 200)
            Text("eBalo")
                .font(.customFont(font: .helvetica, style: .bold, size: 32))
                .foregroundStyle(.dullBlue)
                .padding()
            Text("AI powered ZK Biometric Platform")
                .font(.customFont(font: .helvetica, style: .regular, size: 16))
                .foregroundStyle(.lightGrey)
                .padding(.bottom)
            ZStack {}
                .frame(height: 1)
            IntroInfoView()
            Spacer()
            CommonButtonView("LET'S START") {
                isPassed = true
            }
            Text("Developed By Black Pepper Team")
                .font(.customFont(font: .helvetica, style: .regular, size: 14))
                .foregroundStyle(.lightGrey)
                .padding(.top)
        }
    }
}

struct IntroInfoView: View {
    var body: some View {
        ZStack {
            Color.lightGrey
                .opacity(0.05)
            VStack {
                HStack {
                    Image("InfoIcon")
                    Text("Send assets by eBalo")
                        .foregroundStyle(.lightGrey)
                    Spacer()
                }
                .padding(.bottom)
                HStack {
                    Image("InfoIcon")
                    Text("Manage account by Biometry")
                        .foregroundStyle(.lightGrey)
                    Spacer()
                }
                .padding(.bottom)
                HStack {
                    Image("InfoIcon")
                    Text("Be sure in your security")
                        .foregroundStyle(.lightGrey)
                    Spacer()
                }
                .padding(.bottom)
            }
            .padding()
        }
        .frame(width: 320, height: 150)
    }
}

#Preview {
    IntroView(isPassed: .constant(false))
}
