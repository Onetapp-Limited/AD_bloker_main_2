import SwiftUI

struct StatisticResultsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let value: String
    
    var body: some View {
        HStack(spacing: Layout.Padding.medium) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.tm.title)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.tm.subTitle.opacity(0.7))
            }
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.tm.subTitle)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(iconColor.opacity(0.1))
                .clipShape(Capsule())
            
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(iconColor)
                .frame(width: 28)
        }
        .padding(.horizontal, Layout.Padding.medium)
        .padding(.vertical, Layout.Padding.medium)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.tm.container.opacity(0.95))
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 2)
        )
    }
}
