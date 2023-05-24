//
//  ingredient.swift
//  Recipes
//
//  Created by Vitalii Krasnorutskyi on 15.05.23.
//

import Foundation

class Ingredient : Codable {
    var id: String?
    var name: String
    var unit: String?
    var amount: Double
    
    init(id: String?, name: String, unit: String?, amount: Double) {
        self.id = id
        self.name = name
        self.amount = amount
        self.unit = unit
    }
}
