//
//  RecipesService.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 12/6/22.
//

import Foundation

class HealthService: ServiceBase {
    
    init() {
        super.init(url: "/health")
    }
    
    func check() async -> String? {
        return await HttpClient.shared.getAsTextAsync(baseUrl)
    }
}
