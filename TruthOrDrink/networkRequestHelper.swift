//
//  networkRequestHelper.swift
//  TruthOrDrink
//
//  Created by Menno Spijker on 03/05/2021.
//

import Foundation

class NetworkRequestHelper {
    let url = URL(string: "https://mennospijker.nl/api/dranquilo")!
    
    func request() {
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else {
                print("guard err")
                return
            }
            
            let decoder = JSONDecoder()
            print(data)
            if let dataObject = try? decoder.decode([questionObject].self, from: data) {
                
                var array: [String] = []
                
                for question in dataObject {
                    array.append(question.question)
                }
                
                print(array)
                
                StorageHelper().saveToLocalStorage(arr: array)
            } else {
                print("No questions retrieved...")
            }
        }
        task.resume()
    }
    
}
