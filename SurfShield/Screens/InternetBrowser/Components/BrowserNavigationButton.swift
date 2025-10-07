//
//  BrowserNavigationButton.swift
//  SufrShield
//
//  Created by Артур Кулик on 03.09.2025.
//

import SwiftUI

enum BrowserNavigationButtonType {
    case back
    case forward
    case refresh
    case share
    
    var iconName: String {
        switch self {
        case .back:
            return "chevron.left"
        case .forward:
            return "chevron.right"
        case .refresh:
            return "arrow.clockwise"
        case .share:
            return "square.and.arrow.up"
        }
    }
    
    var isEnabled: Bool {
        switch self {
        case .back, .forward:
            return false // Будет передаваться извне
        case .refresh, .share:
            return true
        }
    }
}

struct BrowserNavigationButton: View {
    let type: BrowserNavigationButtonType
    let action: () -> Void
    let isEnabled: Bool
    
    init(_ type: BrowserNavigationButtonType, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.type = type
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Контейнер с тенью
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: .black.opacity(0.1),
                        radius: 2,
                        x: 0,
                        y: 1
                    )
                    .shadow(
                        color: .black.opacity(0.05),
                        radius: 1,
                        x: 0,
                        y: 0
                    )
                    .frame(width: 36, height: 36)
                
                // Иконка
                Image(systemName: type.iconName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isEnabled ? .primary : .secondary)
            }
        }
        .disabled(!isEnabled)
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .opacity(isEnabled ? 1.0 : 0.6)
    }
}
