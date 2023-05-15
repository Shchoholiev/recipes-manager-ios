//
//  ingredient.swift
//  Recipes
//
//  Created by Vitalii Krasnorutskyi on 15.05.23.
//

import Foundation

class Ingredient : Codable {
    var id: String
    var name: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
