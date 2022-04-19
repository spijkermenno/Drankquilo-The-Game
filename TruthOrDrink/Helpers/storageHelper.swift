//
//  storageHelper.swift
//  TruthOrDrink
//
//  Created by Menno Spijker on 03/05/2021.
//

import Foundation

class StorageHelper {
    let defaults = UserDefaults.standard
    
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    let QuestionsStorageIdentifier: String = "Questions"
    let CommandsStorageIdentifier: String = "Commands"
    let IAPStorageIdentifier: String = "IAP"
    let UUIDStorageIdentifier: String = "UUID"

    func saveToLocalStorage(arr: [String], storageType: StorageIdentifier) {
        switch storageType {
        case .Questions:
            defaults.set(arr, forKey: QuestionsStorageIdentifier)
            return
        case .UUID:
            return
        case .IAP:
            return
        case .Commands:
            defaults.set(arr, forKey: CommandsStorageIdentifier)
            return
        }
    }
    
    func saveToLocalStorage(string: String, storageType: StorageIdentifier) {
        switch storageType {
        case .Questions:
            return
        case .UUID:
            defaults.set(string, forKey: UUIDStorageIdentifier)
            return
        case .IAP:
            defaults.set(string, forKey: IAPStorageIdentifier)
            return
        case .Commands:
            return
        }
    }
    
    func saveToLocalStorage(bool: Bool, storageType: StorageIdentifier) {
        switch storageType {
        case .Questions:
            return
        case .UUID:
            return
        case .IAP:
            defaults.set(bool, forKey: IAPStorageIdentifier)
            return
        case .Commands:
            return
        }
    }
    
    func retrieveFromLocalStorage(storageType: StorageIdentifier) -> [String] {
        switch storageType {
        case .Questions:
            if let result = defaults.object(forKey: QuestionsStorageIdentifier) as? [String] {
                return result
            }
        case .UUID:
            return []
        case .IAP:
            return []
        case .Commands:
            if let result = defaults.object(forKey: CommandsStorageIdentifier) as? [String] {
                return result
            }
        }
        
        return []
    }
    
    func retrieveFromLocalStorage(storageType: StorageIdentifier) -> String {
        switch storageType {
        case .Questions:
            return ""
        case .UUID:
            if let result = defaults.object(forKey: UUIDStorageIdentifier) as? String {
                return result
            }
        case .IAP:
            if let result = defaults.object(forKey: IAPStorageIdentifier) as? String {
                return result
            }
        case .Commands:
            return ""
        }
        
        return ""
    }
    
    func retrieveFromLocalStorage(storageType: StorageIdentifier) -> Bool {
        switch storageType {
        case .Questions:
            return false
        case .UUID:
            return false
        case .IAP:
            if let result = defaults.object(forKey: IAPStorageIdentifier) as? Bool {
                return result
            }
        case .Commands:
            return false
        }
        
        return false
    }
}
