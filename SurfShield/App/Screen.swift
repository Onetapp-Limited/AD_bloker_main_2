//
//  Screen.swift
//  Lumio
//
//  Created by Артур Кулик on 22.08.2025.
//

import Foundation

enum Screen: Hashable, Identifiable {
    
    case paywall
    
    
    var id: String {
        switch self {
        case .paywall:
            return "payWall"
        }
    }
    
    static func == (lhs: Screen, rhs: Screen) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .paywall:
            return hasher.combine(UUID())
        }
    }
}

