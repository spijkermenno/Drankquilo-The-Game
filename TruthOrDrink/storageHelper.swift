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
    
    func saveToLocalStorage(arr: [String]) {
        defaults.set(arr, forKey: "questions")
    }
    
    func retrieveFromLocalStorage() -> [String] {
        if let result = defaults.object(forKey: "questions") as? [String] {
            return result
        }
        return []
    }
    
    func retrieveUUID() -> String {
        let a = defaults.string(forKey: "uuid")
        
        if a == nil {
            return ""
        }
        return defaults.string(forKey: "uuid")!
    }
    
    func setUUID(uuid: String) {
        defaults.setValue(uuid, forKey: "uuid")
    }
}