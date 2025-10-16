import SwiftUI

struct PrivacyRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Layout.Padding.medium) {
                VStack(alignment: .leading, spacing: Layout.Padding.small) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.tm.title)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.tm.subTitle.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.tm.subTitle.opacity(0.5))
                
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(accentColor)
                }
            }
            .padding(.vertical, Layout.Padding.smallExt)
            .padding(.horizontal, Layout.Padding.medium)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.tm.container.opacity(0.95))
                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
