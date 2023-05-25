//
//  Recipe.swift
//  Recipes
//
//  Created by Vitalii Krasnorutskyi on 15.05.23.
//

import Foundation

class Recipe : Codable {
    var id: String
    var name: String
    var thumbnail: Image?
    var ingredients: [Ingredient]?
    var ingredientsText: String?
    var text: String?
    var categories: [Category]
    var calories: Int?
    var servingsCount: Int?
    var isPublic: Bool?
    var isSaved: Bool?
    var createdById: String
    var createdDateUtc: Date?
    
    init(id: String, name: String, thumbnail: Image?, ingredients: [Ingredient]?, ingredientsText: String?, categories: [Category], calories: Int?, servingsCount: Int?, isPublic: Bool?, isSaved: Bool?, createdById: String, createdDateUtc: Date?, text: String?) {
        self.id = id
        self.name = name
        self.thumbnail = thumbnail
        self.ingredients = ingredients
        self.ingredientsText = ingredientsText
        self.categories = categories
        self.calories = calories
        self.servingsCount = servingsCount
        self.isPublic = isPublic
        self.isSaved = isSaved
        self.createdById = createdById
        self.createdDateUtc = createdDateUtc
        self.text = text
    }
}
