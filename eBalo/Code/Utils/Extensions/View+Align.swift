import SwiftUI

extension View {
    func align(_ aligment: Alignment = .trailing) -> some View {
        self.frame(maxWidth: .infinity, alignment: aligment)
    }
}

