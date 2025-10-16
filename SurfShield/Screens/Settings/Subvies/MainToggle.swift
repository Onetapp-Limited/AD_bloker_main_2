import SwiftUI

struct MainToggle: View {
    @Binding var isOn: Bool
    let accentColor: Color
    let isDisabled: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    isOn && !isDisabled ?
                    accentColor.opacity(0.8) :
                    .tm.title.opacity(0.2)
                )
                .frame(width: 48, height: 28)
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 2)
            
            Circle()
                .fill(Color.white)
                .frame(width: 24, height: 24)
                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
                .offset(x: isOn ? 10 : -10)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOn)
        }
        .disabled(isDisabled)
    }
}
