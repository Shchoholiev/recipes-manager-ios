//
//  RecipesService.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 12/6/22.
//

import Foundation

class RecipesService: ServiceBase {
    
    init() {
        super.init(url: "/recipes")
    }
    
    func getPageAsync(pageNumber: Int) async -> PaginationWrapper<Recipe>? {
        let url = URL(string: "\(baseUrl)/page/\(pageNumber)")
        if let safeUrl = url {
            do {
                let (data, _) = try await URLSession.shared.data(from: safeUrl)
                let recipes = try JSONDecoder().decode(PaginationWrapper<Recipe>.self, from: data)
                return recipes
            } catch {
                print(error)
            }
        }
        
        return nil
    }
    
    func getPageAsync(pageNumber: Int, filter: String) async -> PaginationWrapper<Recipe>? {
        let encodedFilter = filter.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlHostAllowed)
        if let safeFilter = encodedFilter {
            let url = URL(string: "\(baseUrl)/page/\(pageNumber)/\(safeFilter)")
            if let safeUrl = url {
                do {
                    let (data, _) = try await URLSession.shared.data(from: safeUrl)
                    let recipes = try JSONDecoder().decode(PaginationWrapper<Recipe>.self, from: data)
                    return recipes
                } catch {
                    print(error)
                }
            }
        }
        
        return nil
    }
    
    func getPageAsync(pageNumber: Int, categoryId: Int) async -> PaginationWrapper<Recipe>? {
        let url = URL(string: "\(baseUrl)/page-by-category-id/\(pageNumber)/\(categoryId)")
        if let safeUrl = url {
            do {
                let (data, _) = try await URLSession.shared.data(from: safeUrl)
                let recipes = try JSONDecoder().decode(PaginationWrapper<Recipe>.self, from: data)
                return recipes
            } catch {
                print(error)
            }
        }
        
        return nil
    }
    
    func getRecipeAsync(id: Int) async -> Recipe? {
        let url = URL(string: "\(baseUrl)/\(id)")
        if let safeUrl = url {
            do {
                let (data, _) = try await URLSession.shared.data(from: safeUrl)
                let recipe = try JSONDecoder().decode(Recipe.self, from: data)
                return recipe
            } catch {
                print(error)
            }
        }
        
        return nil
    }
    
    func createRecipe(_ recipe: Recipe) async -> Bool {
        let url = URL(string: baseUrl)
        if let safeUrl = url {
            do {
                let jsonEncoder = JSONEncoder()
                let jsonData = try jsonEncoder.encode(recipe)
                
                var request = URLRequest(url: safeUrl)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                
                let (data, _) = try await URLSession.shared.data(for: request)
                let str = String(data: data, encoding: .utf8)
                if let response = str, response.isEmpty {
                    return true
                }
            } catch {
                print(error)
            }
        }
        
        return false
    }
    
    func deleteAsync(id: Int) async -> Bool {
        let url = URL(string: "\(baseUrl)/\(id)")
        if let safeUrl = url {
            do {
                var request = URLRequest(url: safeUrl)
                request.httpMethod = "DELETE"
                
                let (data, _) = try await URLSession.shared.data(for: request)
                let str = String(data: data, encoding: .utf8)
                if let response = str, response.isEmpty {
                    return true
                }
            } catch {
                print(error)
            }
        }
        
        return false
    }
    
    func updateRecipe(_ recipe: Recipe) async -> Bool {
        let url = URL(string: "\(baseUrl)/\(recipe.id)")
        if let safeUrl = url {
            do {
                let jsonEncoder = JSONEncoder()
                let jsonData = try jsonEncoder.encode(recipe)
                
                var request = URLRequest(url: safeUrl)
                request.httpMethod = "PUT"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                
                let (data, _) = try await URLSession.shared.data(for: request)
                let str = String(data: data, encoding: .utf8)
                if let response = str, response.isEmpty {
                    return true
                }
            } catch {
                print(error)
            }
        }
        
        return false
    }
}
