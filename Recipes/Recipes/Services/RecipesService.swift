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
    
//    func getPageAsync(pageNumber: Int) async -> PaginationWrapper<RecipeOld>? {
//        let url = URL(string: "\(baseUrl)/page/\(pageNumber)")
//        if let safeUrl = url {
//            do {
//                let (data, _) = try await URLSession.shared.data(from: safeUrl)
//                let recipes = try JSONDecoder().decode(PaginationWrapper<RecipeOld>.self, from: data)
//                return recipes
//            } catch {
//                print(error)
//            }
//        }
//        
//        return nil
//    }
    
    func getPageAsync(pageNumber: Int = 1, pageSize: Int = 10, searchType: RecipesSearchTypes = .PUBLIC, search: String = "", categoriesIds: [String] = [], authorId: String = "") async -> PagedList<Recipe>? {
        let request = GraphQlRequest(
            query: """
               query RecipeSearchResult($recipeSearchType: RecipesSearchTypes!, $pageNumber: Int!, $pageSize: Int!, $categoriesIds: [String!], $searchString: String!, $authorId: String!) {
                 searchRecipes(recipeSearchType: $recipeSearchType, pageNumber: $pageNumber, pageSize: $pageSize, categoriesIds: $categoriesIds, searchString: $searchString, authorId: $authorId) {
                   items {
                     id
                     name
                     categories {
                       id
                       name
                     }
                     thumbnail {
                        
                        
                        smallPhotoGuid
                        extension
                        
            
                     }
                     createdById
                     createdDateUtc
                     createdBy {
                       id
                       name
                     }
                   },
                   totalPages
                 }
               }
            """,
            variables: [
                "pageNumber": pageNumber,
                "pageSize": pageSize,
                "recipeSearchType": searchType.name,
                "searchString": search,
                "categoriesIds": categoriesIds,
                "authorId": authorId
            ]
        )
        let response: GraphQlGenericResponse<PagedList<Recipe>> = await HttpClient.shared.queryAsync(request, propertyName: "searchRecipes")
    
        return response.data;
    }
    
    func getPageAsync(pageNumber: Int, filter: String) async -> PaginationWrapper<RecipeOld>? {
        let encodedFilter = filter.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlHostAllowed)
        if let safeFilter = encodedFilter {
            let url = URL(string: "\(baseUrl)/page/\(pageNumber)/\(safeFilter)")
            if let safeUrl = url {
                do {
                    let (data, _) = try await URLSession.shared.data(from: safeUrl)
                    let recipes = try JSONDecoder().decode(PaginationWrapper<RecipeOld>.self, from: data)
                    return recipes
                } catch {
                    print(error)
                }
            }
        }
        
        return nil
    }
    
    func getPageAsync(pageNumber: Int, categoryId: Int) async -> PaginationWrapper<RecipeOld>? {
        let url = URL(string: "\(baseUrl)/page-by-category-id/\(pageNumber)/\(categoryId)")
        if let safeUrl = url {
            do {
                let (data, _) = try await URLSession.shared.data(from: safeUrl)
                let recipes = try JSONDecoder().decode(PaginationWrapper<RecipeOld>.self, from: data)
                return recipes
            } catch {
                print(error)
            }
        }
        
        return nil
    }
    
    func getRecipeAsync(id: Int) async -> RecipeOld? {
        let url = URL(string: "\(baseUrl)/\(id)")
        if let safeUrl = url {
            do {
                let (data, _) = try await URLSession.shared.data(from: safeUrl)
                let recipe = try JSONDecoder().decode(RecipeOld.self, from: data)
                return recipe
            } catch {
                print(error)
            }
        }
        
        return nil
    }
    
    func getRecipeAsync(id: String) async -> Recipe? {
        let request = GraphQlRequest(
            query: """
               query Query($recipeId: String!) {
                 recipe(id: $recipeId) {
                   name
                   minutesToCook
                   isSaved
                   ingredientsText
                   createdById
                   categories {
                     id
                     name
                   }
                   text
                   thumbnail {
                     originalPhotoGuid
                     extension
                   }
                   calories
                   id
                 }
               }
            """,
            variables: [
                "recipeId": id
            ]
        )
        let response: GraphQlGenericResponse<Recipe> = await HttpClient.shared.queryAsync(request, propertyName: "recipe")
        print(response.data)
        return response.data;
    }
    
    func createRecipe(_ recipe: RecipeOld) async -> Bool {
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
    
    func updateRecipe(_ recipe: RecipeOld) async -> Bool {
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
