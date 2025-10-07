//
//  BackgroundGradient.swift
//  SufrShield
//
//  Created by Артур Кулик on 26.08.2025.
//

import SwiftUI

struct BackgroundGradient: View {
    
    var isHighlight: Bool = false
    
    var body: some View {
        LinearGradient(
            colors: isHighlight
                ? [Color.tm.background, Color.tm.background.opacity(0.8), Color.tm.accentSecondary.opacity(0.1)]
                : [Color.tm.background, Color.tm.background.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .background(Color.tm.background)
    }
}

#Preview {
    BackgroundGradient()
}
