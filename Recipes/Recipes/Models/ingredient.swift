//
//  ingredient.swift
//  Recipes
//
//  Created by Vitalii Krasnorutskyi on 15.05.23.
//

import Foundation

class Ingredient : Codable {
    var name: String
    var units: String?
    var amount: Double
    
    init(name: String, units: String?, amount: Double) {
        self.name = name
        self.amount = amount
        self.units = units
    }
}
