//
//  networkRequestHelper.swift
//  TruthOrDrink
//
//  Created by Menno Spijker on 03/05/2021.
//

import Foundation

class NetworkRequestHelper {
    let url = URL(string: "")!
    
    func request() {
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else {
                print("guard err")
                return
            }
            
            let decoder = JSONDecoder()
            if let dataObject = try? decoder.decode([questionObject].self, from: data) {
                
                var array: [String] = []
                
                for question in dataObject {
                    savedGameRules.append(question.question)
                    array.append(question.question)
                }
                
                StorageHelper().saveToLocalStorage(arr: array)
            }
        }
        task.resume()
    }
    
}
