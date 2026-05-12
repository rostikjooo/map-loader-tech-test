//
//  Storage.swift
//  MapLoader
//
//  Created by Rost on 12.05.2026.
//

import Foundation

@propertyWrapper
public class Storage<T: Codable> {

    private let key: String
    private let defaultValue: T
    private let storage: KeyValueStorage

    /// constructor for property wrapper
    /// - Parameters:
    ///   - key: key for KeyValueStorage which userDefaults is
    ///   - fallback: default value
    ///   - storage: key value storage
    init(
        key: String, fallback: T,
        storage: KeyValueStorage = UserDefaults.standard
    ) {
        self.key = key
        self.defaultValue = fallback
        self.storage = storage
    }

    public var wrappedValue: T {
        get {
            getValue()
        }
        set {
            store(newValue)
        }
    }

}

extension Storage {
    internal func getValue() -> T {
        guard let data = storage.object(forKey: key) as? Data else {
            return defaultValue
        }

        return (try? JSONDecoder().decode(T.self, from: data)) ?? defaultValue
    }

    internal func store(_ value: T) {
        if let data = try? JSONEncoder().encode(value) {
            storage.set(data, forKey: key)
        }
    }
}

protocol KeyValueStorage {
    func object(forKey: String) -> Any?
    func set(_: Any?, forKey: String)
}

extension UserDefaults: KeyValueStorage {}
