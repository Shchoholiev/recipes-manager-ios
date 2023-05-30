//
//  CreateSavedRecipe.swift
//  Recipes
//
//  Created by Vitalii Krasnorutskyi on 25.05.23.
//

import Foundation

class CreateSavedRecipe: Codable {
    var recipeId: String?
    
    init(recipeId: String?) {
        self.recipeId = recipeId
    }
}
