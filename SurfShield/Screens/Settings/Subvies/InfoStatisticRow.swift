import SwiftUI

struct InfoStatisticRow: View {
    let iconColor: Color
    let title: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: .smallExt) {
            (Text(title)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.tm.title)
             +
             Text(text)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.tm.subTitle.opacity(0.7)))
            
            Text("•")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(iconColor)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.tm.container.opacity(0.9))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}
