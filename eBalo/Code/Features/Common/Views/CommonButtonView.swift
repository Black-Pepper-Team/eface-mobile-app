//
//  CommonButtonView.swift
//  Verify 2024
//
//  Created by Ivan Lele on 19.03.2024.
//

import SwiftUI

struct CommonButtonView: View {
    let text: String
    let onClick: () -> Void
    
    init(_ text: String, onClick: @escaping () -> Void) {
        self.text = text
        self.onClick = onClick
    }
    
    var body: some View {
        Button(action: onClick) {
            ZStack {
                RoundedRectangle(cornerRadius: 1_000)
                    .foregroundStyle(.dullBlue)
                Text(LocalizedStringKey(text))
                    .font(.customFont(font: .helvetica, style: .bold, size: 14))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 326, height: 48)
    }
}

#Preview {
    CommonButtonView("Preview") {}
}
