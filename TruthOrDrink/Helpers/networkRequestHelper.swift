//
//  networkRequestHelper.swift
//  TruthOrDrink
//
//  Created by Menno Spijker on 03/05/2021.
//

import Foundation

class NetworkRequestHelper {
    let urlQuestions = URL(string: "https://ondergrondseontwikkeling.nl/api/questions")!
    let urlCommands = URL(string: "https://ondergrondseontwikkeling.nl/api/commands")!
    
    func request() {
        print("Request...")
        
        let retrieveQuestions = URLSession.shared.dataTask(with: urlQuestions) {(data, response, error) in
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
                
                StorageHelper().saveToLocalStorage(arr: array, storageType: StorageIdentifier.Questions)
            } else {
                print("No questions retrieved...")
            }
        }
        
        let retrieveCommands = URLSession.shared.dataTask(with: urlCommands) {(data, response, error) in
            guard let data = data else {
                print("guard err")
                return
            }
            
            let decoder = JSONDecoder()
            print(data)
            if let dataObject = try? decoder.decode([commandObject].self, from: data) {
                
                var array: [String] = []
                
                for command in dataObject {
                    array.append(command.command)
                }
                
                print(array)
                
                StorageHelper().saveToLocalStorage(arr: array, storageType: StorageIdentifier.Commands)
            } else {
                print("No commands retrieved...")
            }
        }
        
        
        retrieveQuestions.resume()
        retrieveCommands.resume()
    }
    
}
