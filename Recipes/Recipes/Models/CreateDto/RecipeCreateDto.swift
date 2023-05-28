//
//  CreateDto.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 5/27/23.
//

import Foundation

class RecipeCreateDto {
    public var name: String
    public var text: String?
    public var thumbnail: Data?
    public var ingredients: [Ingredient]?
    public var ingredientsText: String?
    public var categories: [Category]
    public var calories: Int?
    public var servingsCount: Int?
    public var minutesToCook: Int?
    public var isPublic: Bool

    public init(name: String, text: String?, thumbnail: Data?, ingredients: [Ingredient]?, ingredientsText: String?, categories: [Category], calories: Int?, servingsCount: Int?, minutesToCook: Int?, isPublic: Bool) {
        self.name = name
        self.text = text
        self.thumbnail = thumbnail
        self.ingredients = ingredients
        self.ingredientsText = ingredientsText
        self.categories = categories
        self.calories = calories
        self.servingsCount = servingsCount
        self.minutesToCook = minutesToCook
        self.isPublic = isPublic
    }
}
