import SwiftUI

struct ELeleAssistentButton: View {
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .foregroundColor(.dullBlue)
                    .frame(width: 50, height: 50)
                Image(Icons.assistentIcon)
                    .resizable()
                    .frame(width: 35, height: 35)
            }
        }
    }
}

#Preview {
    ELeleAssistentButton()
}
