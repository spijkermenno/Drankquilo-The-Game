//
//  PurchasableData.swift
//  TruthOrDrink
//
//  Created by Menno Spijker on 16/04/2022.
//

import Foundation
import StoreKit

class PurchasableData {
    
    struct GameData: Codable, SettingsManageable {
        
        var removedAds = false
    }
    
    var gameData = GameData()
    
    var products = [SKProduct]()
    
    
    init() {
        _ = gameData.load()
    }
    
    
    func getProduct(containing keyword: String) -> SKProduct? {
        return products.filter { $0.productIdentifier.contains(keyword) }.first
    }
}
