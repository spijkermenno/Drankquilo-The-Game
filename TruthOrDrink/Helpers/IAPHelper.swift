//
//  IAPManager.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 08/06/2021.
//

import StoreKit

class IAPManager: NSObject {
    static let shared = IAPManager()
    
    var onRecieveProductsHandler: ((Result<[SKProduct], IAPManagerError>) -> Void)?
    
    var onBuyProductHandler: ((Result<Bool, Error>) -> Void)?
        
    var totalRestoredPurchases = 0
    
    override init() {
        super.init()
    }
    
    func startObserving() {
        SKPaymentQueue.default().add(self)
    }


    func stopObserving() {
        SKPaymentQueue.default().remove(self)
    }
    
    
    func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }

    fileprivate func getProductIDs() -> [String]? {
        // Get all available store items from plist file
        guard let url = Bundle.main.url(forResource: "IAP_ProductIDs", withExtension: "plist") else {return nil}
        do {
            // retrieve data from url
            let data = try Data(contentsOf: url)
            // translate data to json like material
            let productIDs = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as? [String] ?? []
            
            return productIDs
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func getProducts(withHandler productsRecieveHandler: @escaping (_ result: Result<[SKProduct], IAPManagerError>) -> Void) {
        // set the product recieve handler and assign it to a file global variable
        onRecieveProductsHandler = productsRecieveHandler
        
        // get product ids and guard that the object is not empty
        guard let productIDs = getProductIDs() else {
            productsRecieveHandler(.failure(.noProductIDsFound))
            return
        }
        
        print(productIDs)
        
        // start requesting data from apple
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        
        request.start()
    }
    
    func getPriceFormatted(for product: SKProduct) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price)
    }
    
    func buy(product: SKProduct, withHandler handler: @escaping ((_ result: Result<Bool, Error>) -> Void)) {
        print("buy")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)

        // Keep the completion handler.
        onBuyProductHandler = handler
    }
    
    
    func restorePurchases(withHandler handler: @escaping ((_ result: Result<Bool, Error>) -> Void)) {
        print("restorePurchases1")
        print(handler)
        onBuyProductHandler = handler
        print("restorePurchases2")
        print(onBuyProductHandler)
        totalRestoredPurchases = 0
        print("restorePurchases3")
        SKPaymentQueue.default().restoreCompletedTransactions()
        print("restorePurchases4")
    }

    enum IAPManagerError: Error {
        case noProductIDsFound
        case noProductsFound
        case paymentWasCancelled
        case productRequestFailed
    }
}

extension IAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("transaction queue")
        transactions.forEach { (transaction) in
            print(transaction)
            switch transaction.transactionState {
            case .purchased:
                onBuyProductHandler?(.success(true))
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .restored:
                totalRestoredPurchases += 1
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .failed:
                if let error = transaction.error as? SKError {
                    if error.code != .paymentCancelled {
                        onBuyProductHandler?(.failure(error))
                    } else {
                        onBuyProductHandler?(.failure(IAPManagerError.paymentWasCancelled))
                    }
                    print("IAP Error:", error.localizedDescription)
                }
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .deferred, .purchasing: print("err????")
            @unknown default: print("unknown")
            }
        }
    }
    
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("queue completed")
        print(totalRestoredPurchases)
        if totalRestoredPurchases != 0 {
            onBuyProductHandler?(.success(true))
        } else {
            print("IAP: No purchases to restore!")
            onBuyProductHandler?(.success(false))
        }
    }
    
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if let error = error as? SKError {
            if error.code != .paymentCancelled {
                print("IAP Restore Error:", error.localizedDescription)
                onBuyProductHandler?(.failure(error))
            } else {
                onBuyProductHandler?(.failure(IAPManagerError.paymentWasCancelled))
            }
        }
    }
    
    

        func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
            print("removed")
        }


        func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
            print("downloading")
        }
}




// MARK: - SKProductsRequestDelegate
extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        // Get the available products contained in the response.
        let products = response.products

        print(products)
        print(products.count)
        
        // Check if there are any products available.
        if products.count > 0 {
            print("products found. SUCCESS")
            // Call the following handler passing the received products.
            onRecieveProductsHandler?(.success(products))
        } else {
            print("no products found. ERROR")
            // No products were found.
            onRecieveProductsHandler?(.failure(.noProductsFound))
        }
    }
    
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        onRecieveProductsHandler?(.failure(.productRequestFailed))
    }
    
    
    func requestDidFinish(_ request: SKRequest) {
        // Implement this method OPTIONALLY and add any custom logic
        // you want to apply when a product request is finished.
    }
}




// MARK: - IAPManagerError Localized Error Descriptions
extension IAPManager.IAPManagerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noProductIDsFound: return "No In-App Purchase product identifiers were found."
        case .noProductsFound: return "No In-App Purchases were found."
        case .productRequestFailed: return "Unable to fetch available In-App Purchase products at the moment."
        case .paymentWasCancelled: return "In-App Purchase process was cancelled."
        }
    }
}
