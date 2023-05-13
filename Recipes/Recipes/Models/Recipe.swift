//
//  Recipe.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 12/6/22.
//

import Foundation

class Recipe: Codable {
    
    let id: Int
    
    let name: String
    
    let ingredients: String?
    
    let text: String?
    
    let thumbnail: String
    
    let category: Category
    
    init(id: Int, name: String, ingredients: String, text: String, thumbnail: String, category: Category) {
        self.id = id
        self.name = name
        self.ingredients = ingredients
        self.text = text
        self.thumbnail = thumbnail
        self.category = category
    }
}
