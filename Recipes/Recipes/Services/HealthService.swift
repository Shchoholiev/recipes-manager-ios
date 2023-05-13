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
        let url = URL(string: "\(baseUrl)/check")
        if let safeUrl = url {
            do {
                let (data, _) = try await URLSession.shared.data(from: safeUrl)
                let text = String(data: data, encoding: .utf8)
                return text
            } catch {
                print(error)
            }
        }
        
        return nil
    }
}
