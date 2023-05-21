//
//  Recipe.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 12/6/22.
//

import Foundation

class RecipeOld: Codable {
    
    let id: Int
    
    let name: String
    
    let ingredients: String?
    
    let text: String?
    
    let thumbnail: String
    
    let category: CategoryOld
    
    init(id: Int, name: String, ingredients: String, text: String, thumbnail: String, category: CategoryOld) {
        self.id = id
        self.name = name
        self.ingredients = ingredients
        self.text = text
        self.thumbnail = thumbnail
        self.category = category
    }
}
