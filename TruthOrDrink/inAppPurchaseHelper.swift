//
//  inAppPurchaseHelper.swift
//  TruthOrDrink
//
//  Created by Menno Spijker on 04/05/2021.
//

import Foundation
import StoreKit

class inAppPurchaseHelper: NSObject, SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        // Get the available products contained in the response.
            let products = response.products
         
            // Check if there are any products available.
            if products.count > 0 {
                // Call the following handler passing the received products.
                onReceiveProductsHandler?(.success(products))
            } else {
                // No products were found.
                onReceiveProductsHandler?(.failure(.noProductsFound))
            }
    }
    
    static let shared = inAppPurchaseHelper()
    
    var onReceiveProductsHandler: ((Result<[SKProduct], inAppPurchaseHelperError>) -> Void)?
    
    private override init() {
        super.init()
    }
    
    func getPriceFormatted(for product: SKProduct) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price)
    }
    
    func getProducts(withHandler productsReceiveHandler: @escaping (_ result: Result<[SKProduct], inAppPurchaseHelperError>) -> Void) {
        // Keep the handler (closure) that will be called when requesting for
        // products on the App Store is finished.
        onReceiveProductsHandler = productsReceiveHandler
     
        // Get the product identifiers.
        guard let productIDs = getProductIDs() else {
            productsReceiveHandler(.failure(.noProductIDsFound))
            return
        }
             
        // Initialize a product request.
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
     
        // Set self as the its delegate.
        request.delegate = self
     
        // Make the request.
        request.start()
    }
    
    fileprivate func getProductIDs() -> [String]? {

        guard let url = Bundle.main.url(forResource: "purchasableProducts", withExtension: "plist") else {
            print(inAppPurchaseHelperError.noProductIDsFound)
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            
            
            let productIDs = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as? [String] ?? []
            return productIDs
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    enum inAppPurchaseHelperError: Error {
        case noProductIDsFound
        case noProductsFound
        case paymentWasCancelled
        case productRequestFailed
    }
}

extension inAppPurchaseHelper.inAppPurchaseHelperError: LocalizedError {
    var errorDescription: String? {
            switch self {
            case .noProductIDsFound: return "No In-App Purchase product identifiers were found."
            case .noProductsFound: return "No In-App Purchases were found."
            case .productRequestFailed: return "Unable to fetch available In-App Purchase products at the moment."
            case .paymentWasCancelled: return "In-App Purchase process was cancelled."
            }
        }
}
