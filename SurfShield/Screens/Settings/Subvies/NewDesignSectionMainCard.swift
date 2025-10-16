import SwiftUI

struct NewDesignSectionMainCard<Content: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    let content: Content
    
    init(
        title: String,
        subtitle: String,
        icon: String,
        accentColor: Color,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.accentColor = accentColor
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: Layout.Padding.regularExt) {
                VStack(alignment: .leading, spacing: Layout.Padding.small) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(.tm.title)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.tm.subTitle.opacity(0.7))
                }
                
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 48, height: 48)
                        .shadow(color: accentColor.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(accentColor)
                }
            }
            .padding(.bottom, Layout.Padding.mediumExt)
            
            VStack(spacing: 0) {
                content
            }
            .padding(Layout.Padding.mediumExt)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.tm.container.opacity(1.0),
                                Color.tm.container.opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
        }
        .padding(.horizontal, Layout.Padding.smallExt)
    }
}
