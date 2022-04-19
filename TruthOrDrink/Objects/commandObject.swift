//
//  commandObject.swift
//  TruthOrDrink
//
//  Created by Menno Spijker on 16/04/2022.
//

import Foundation

struct commandObject: Decodable {
    var id: Int!
    var command: String!
    var created_at: String!
    var updated_at: String!
    var validated: String!
    var author: String!
}
