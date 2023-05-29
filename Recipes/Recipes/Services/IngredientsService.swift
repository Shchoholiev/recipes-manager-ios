//
//  IngredientsService.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 5/28/23.
//

import Foundation

class IngredientsService {
    
    func parseIngredients(_ text: String) async throws -> AsyncStream<Ingredient> {
        return try await HttpClient.shared.readSSE("api/ingredients/parse", .post, [ "text": text ])
    }
    
    func estimateCalories(_ ingredients: [Ingredient]) async throws -> AsyncStream<Ingredient> {
        return try await HttpClient.shared.readSSE("api/ingredients/estimate-calories", .post, ingredients)
    }
    
    
    func calculateTotalCalories(_ ingredients: [Ingredient]) -> Int {
        var totalCalories = 0
            
        for ingredient in ingredients {
            if let calories = ingredient.totalCalories {
                totalCalories += calories
            }
        }
        
        return totalCalories
    }
}
