import Foundation

/// Сервис для работы с UserDefaults с поддержкой generic типов и enum ключей
class UserDefaultsService {
    
    static let shared = UserDefaultsService()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Generic Methods
    
    /// Сохраняет объект в UserDefaults по указанному ключу
    /// - Parameters:
    ///   - object: Объект для сохранения (должен соответствовать протоколу Codable)
    ///   - key: Ключ из enum UserDefaultsKeys
    func save<T: Codable>(_ object: T, forKey key: UserDefaultsKeys) {
        do {
            let data = try JSONEncoder().encode(object)
            userDefaults.set(data, forKey: key.key)
            print("✅ UserDefaultsService: Объект сохранен для ключа '\(key.key)'")
        } catch {
            print("❌ UserDefaultsService: Ошибка сохранения объекта для ключа '\(key.key)': \(error)")
        }
    }
    
    /// Загружает объект из UserDefaults по указанному ключу
    /// - Parameters:
    ///   - type: Тип объекта для загрузки
    ///   - key: Ключ из enum UserDefaultsKeys
    /// - Returns: Загруженный объект или nil, если объект не найден или произошла ошибка
    func load<T: Codable>(_ type: T.Type, forKey key: UserDefaultsKeys) -> T? {
        guard let data = userDefaults.data(forKey: key.key) else {
            print("⚠️ UserDefaultsService: Данные не найдены для ключа '\(key.key)'")
            return nil
        }
        
        do {
            let object = try JSONDecoder().decode(type, from: data)
            print("✅ UserDefaultsService: Объект загружен для ключа '\(key.key)'")
            return object
        } catch {
            print("❌ UserDefaultsService: Ошибка загрузки объекта для ключа '\(key.key)': \(error)")
            return nil
        }
    }
    
    /// Удаляет объект из UserDefaults по указанному ключу
    /// - Parameter key: Ключ из enum UserDefaultsKeys
    func delete(forKey key: UserDefaultsKeys) {
        userDefaults.removeObject(forKey: key.key)
        print("🗑️ UserDefaultsService: Объект удален для ключа '\(key.key)'")
    }
}
