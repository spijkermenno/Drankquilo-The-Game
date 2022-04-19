//
//  questionObject.swift
//  TruthOrDrink
//
//  Created by Menno Spijker on 03/05/2021.
//

import Foundation

struct questionObject: Decodable {
    var id: Int!
    var question: String!
    var created_at: String!
    var updated_at: String!
    var validated: String!
    var author: String!
}
