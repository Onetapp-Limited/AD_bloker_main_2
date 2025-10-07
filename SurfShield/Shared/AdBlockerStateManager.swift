//
//  AdBlockerStateManager.swift
//  SufrShield
//
//  Created by Артур Кулик on 25.08.2025.
//

import Foundation
import Combine

/// Менеджер состояния блокировщика рекламы - только для чтения
@MainActor
class AdBlockerStateManager: ObservableObject {
    static let shared = AdBlockerStateManager()
    
    @Published private(set) var isEnabled: Bool = false
    
    private struct UserDefaultsKeys {
        static let adBlockerEnabled = "adBlockerEnabled"
    }
    
    private init() {
        loadState()
    }
    
    /// Загружает сохраненное состояние из UserDefaults
    private func loadState() {
        isEnabled = UserDefaults.standard.bool(forKey: UserDefaultsKeys.adBlockerEnabled)
        print("📱 Загружено состояние блокировщика: \(isEnabled ? "включен" : "выключен")")
    }
    
    /// Обновляет состояние (вызывается только из RulesConverter)
    internal func updateState(_ newState: Bool) {
        isEnabled = newState
    }
    
    /// Получает текущее состояние
    static func getCurrentState() async -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultsKeys.adBlockerEnabled)
    }
    
    /// Сохраняет состояние (вызывается только из RulesConverter)
    static func saveState(_ isEnabled: Bool) async {
        UserDefaults.standard.set(isEnabled, forKey: UserDefaultsKeys.adBlockerEnabled)
        print("💾 Состояние блокировщика сохранено: \(isEnabled ? "включен" : "выключен")")
        
        // Обновляем опубликованное состояние
        await MainActor.run {
            shared.updateState(isEnabled)
        }
    }
    
    /// Сбрасывает состояние (для отладки)
    static func reset() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.adBlockerEnabled)
        Task { @MainActor in
            shared.updateState(false)
        }
        print("🔄 Состояние блокировщика сброшено")
    }
}
