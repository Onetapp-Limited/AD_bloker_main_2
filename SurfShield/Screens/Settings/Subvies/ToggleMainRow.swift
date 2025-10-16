import SwiftUI

struct ToggleMainRow: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool
    let accentColor: Color
    let isDisabled: Bool
    
    init(
        title: String,
        subtitle: String,
        icon: String,
        isOn: Binding<Bool>,
        accentColor: Color,
        isDisabled: Bool = false
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self._isOn = isOn
        self.accentColor = accentColor
        self.isDisabled = isDisabled
    }
    
    var body: some View {
        HStack(spacing: .zero) {
            VStack(alignment: .leading, spacing: Layout.Padding.small) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(isDisabled ? .tm.title.opacity(0.5) : .tm.title)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(isDisabled ? .tm.subTitle.opacity(0.4) : .tm.subTitle.opacity(0.7))
            }
            
            Spacer()
            
            MainToggle(isOn: $isOn, accentColor: accentColor, isDisabled: isDisabled)
                .padding(.trailing, .medium)
            
            ZStack {
                Circle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .shadow(color: accentColor.opacity(isDisabled ? 0.1 : 0.25), radius: 8, x: 0, y: 4)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(isDisabled ? .tm.subTitle.opacity(0.4) : accentColor)
            }
        }
        .padding(.vertical, Layout.Padding.smallExt)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.tm.container.opacity(0.95))
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 2)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if !isDisabled {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isOn.toggle()
                }
            }
        }
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}
