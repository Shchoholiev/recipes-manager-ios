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
                   servingsCount
                   isSaved
                   ingredientsText
                   ingredients {
                     name
                     units
                     totalCalories
                     amount
                   }
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
        
        return response.data;
    }
    
    func saveRecipe(id: String) async -> Bool{
        let request = GraphQlRequest(
            query: """
               mutation Mutation($dto: SavedRecipeCreateDtoInput!) {
                 addSavedRecipe(dto: $dto) {
                   recipeId
                 }
               }
            """,
            variables: [
                "dto": ["recipeId" : id]
            ]
        )
        let response: GraphQlResponse = await HttpClient.shared.queryAsync(request)
        
        return response.errors == nil
    }
    
    func deleteSaved(id: String) async -> Bool{
        let request = GraphQlRequest(
            query: """
               mutation DeleteSavedRecipe($recipeId: String!) {
                 deleteSavedRecipe(recipeId: $recipeId) {
                   isSuccessful
                 }
               }
            """,
            variables: [
                "recipeId": id
            ]
        )
        let response: GraphQlResponse = await HttpClient.shared.queryAsync(request)
        
        return response.errors == nil
    }
    
    func createRecipe(_ recipe: RecipeCreateDto) async -> Recipe? {
        do {
            let boundary = UUID().uuidString
            let formData = encodeRecipeAsFormData(recipe, boundary: boundary)
            
            let result: Recipe = try await HttpClient.shared.postAsync("recipes", formData, "multipart/form-data; boundary=\(boundary)")
            
            return result
        } catch {
            print(error)
        }
        
        return nil
    }
    
    
    func updateRecipe(_ id: String, _ recipe: RecipeCreateDto) async -> Recipe? {
        do {
            let boundary = UUID().uuidString
            let formData = encodeRecipeAsFormData(recipe, boundary: boundary)
            
            let result: Recipe = try await HttpClient.shared.putAsync("recipes/\(id)", formData, "multipart/form-data; boundary=\(boundary)")
            
            return result
        } catch {
            print(error)
        }
        
        return nil
    }
    
    func encodeRecipeAsFormData(_ recipe: RecipeCreateDto, boundary: String) -> Data {
        var formData = Data()
        
        if let thumbnailData = recipe.thumbnail {
            formData.append(Data("--\(boundary)\r\n".utf8))
            formData.append("Content-Disposition: form-data; name=\"thumbnail\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            formData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            formData.append(thumbnailData)
            formData.append(Data("\r\n".utf8))
        }
        
        formData.append(Data("--\(boundary)\r\n".utf8))
        formData.append(Data("Content-Disposition: form-data; name=\"name\"\r\n\r\n".utf8))
        formData.append(Data(recipe.name.utf8))
        formData.append(Data("\r\n".utf8))
        
        if let text = recipe.text {
            formData.append(Data("--\(boundary)\r\n".utf8))
            formData.append(Data("Content-Disposition: form-data; name=\"text\"\r\n\r\n".utf8))
            formData.append(Data(text.utf8))
            formData.append(Data("\r\n".utf8))
        }
        
        if let ingredients = recipe.ingredients, !ingredients.isEmpty {
            for (index, ingredient) in ingredients.enumerated() {
                formData.append(Data("--\(boundary)\r\n".utf8))
                formData.append(Data("Content-Disposition: form-data; name=\"ingredients[\(index)].name\"\r\n\r\n".utf8))
                formData.append(Data(ingredient.name.utf8))
                formData.append(Data("\r\n".utf8))
                
                if let units = ingredient.units {
                    formData.append(Data("--\(boundary)\r\n".utf8))
                    formData.append(Data("Content-Disposition: form-data; name=\"ingredients[\(index)].units\"\r\n\r\n".utf8))
                    formData.append(Data(units.utf8))
                    formData.append(Data("\r\n".utf8))
                }
                
                if let amount = ingredient.amount {
                    formData.append(Data("--\(boundary)\r\n".utf8))
                    formData.append(Data("Content-Disposition: form-data; name=\"ingredients[\(index)].amount\"\r\n\r\n".utf8))
                    formData.append(Data("\(amount)".utf8))
                    formData.append(Data("\r\n".utf8))
                }
                
                if let totalCalories = ingredient.totalCalories {
                    formData.append(Data("--\(boundary)\r\n".utf8))
                    formData.append(Data("Content-Disposition: form-data; name=\"ingredients[\(index)].totalCalories\"\r\n\r\n".utf8))
                    formData.append(Data("\(totalCalories)".utf8))
                    formData.append(Data("\r\n".utf8))
                }
            }
        }
        
        if let ingredientsText = recipe.ingredientsText {
            formData.append(Data("--\(boundary)\r\n".utf8))
            formData.append(Data("Content-Disposition: form-data; name=\"ingredientsText\"\r\n\r\n".utf8))
            formData.append(Data(ingredientsText.utf8))
            formData.append(Data("\r\n".utf8))
        }
        
        for (index, category) in recipe.categories.enumerated() {
            formData.append(Data("--\(boundary)\r\n".utf8))
            formData.append(Data("Content-Disposition: form-data; name=\"categories[\(index)].id\"\r\n\r\n".utf8))
            formData.append(Data(category.id.utf8))
            formData.append(Data("\r\n".utf8))
            
            formData.append(Data("--\(boundary)\r\n".utf8))
            formData.append(Data("Content-Disposition: form-data; name=\"categories[\(index)].name\"\r\n\r\n".utf8))
            formData.append(Data(category.name.utf8))
            formData.append(Data("\r\n".utf8))
        }
        
        if let calories = recipe.calories {
            formData.append(Data("--\(boundary)\r\n".utf8))
            formData.append(Data("Content-Disposition: form-data; name=\"calories\"\r\n\r\n".utf8))
            formData.append(Data("\(calories)".utf8))
            formData.append(Data("\r\n".utf8))
        }
        
        if let servingsCount = recipe.servingsCount {
            formData.append(Data("--\(boundary)\r\n".utf8))
            formData.append(Data("Content-Disposition: form-data; name=\"servingsCount\"\r\n\r\n".utf8))
            formData.append(Data("\(servingsCount)".utf8))
            formData.append(Data("\r\n".utf8))
        }
        
        if let minutesToCook = recipe.minutesToCook {
            formData.append(Data("--\(boundary)\r\n".utf8))
            formData.append(Data("Content-Disposition: form-data; name=\"minutesToCook\"\r\n\r\n".utf8))
            formData.append(Data("\(minutesToCook)".utf8))
            formData.append(Data("\r\n".utf8))
        }
        
        formData.append(Data("--\(boundary)\r\n".utf8))
        formData.append(Data("Content-Disposition: form-data; name=\"isPublic\"\r\n\r\n".utf8))
        formData.append(Data("\(recipe.isPublic)".utf8))
        formData.append(Data("\r\n".utf8))
        
        formData.append(Data("--\(boundary)--\r\n".utf8))
        
        return formData
    }
    
    func uploadImage(imageData: Data?, blobContainer: String) async -> String? {
        let url = URL(string: "https://shch-recipes-api.azurewebsites.net/api/cloud-storage/upload/\(blobContainer)")
        if let safeUrl = url, let safeImageData = imageData {
            do {
                let boundary = UUID().uuidString
                let filename = UUID().uuidString
                var body = Data()
                body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename).jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(safeImageData)
                body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
                
                var request = URLRequest(url: safeUrl)
                request.httpMethod = "POST"
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                request.httpBody = body
                
                let (data, _) = try await URLSession.shared.data(for: request)
                let imageInfo = try JSONDecoder().decode(ImageInfo.self, from: data)
                return imageInfo.link
            } catch {
                print(error)
            }
        }
        
        return nil
    }
    
//    func createRecipe(_ recipe: RecipeOld) async -> Bool {
//        let url = URL(string: baseUrl)
//        if let safeUrl = url {
//            do {
//                let jsonEncoder = JSONEncoder()
//                let jsonData = try jsonEncoder.encode(recipe)
//                
//                var request = URLRequest(url: safeUrl)
//                request.httpMethod = "POST"
//                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//                request.httpBody = jsonData
//                
//                let (data, _) = try await URLSession.shared.data(for: request)
//                let str = String(data: data, encoding: .utf8)
//                if let response = str, response.isEmpty {
//                    return true
//                }
//            } catch {
//                print(error)
//            }
//        }
//        
//        return false
//    }
    
    func deleteRecipe(_ id: String) async -> Bool{
        let request = GraphQlRequest(
            query: """
               mutation DeleteRecipe($deleteRecipeId: String!) {
                 deleteRecipe(id: $deleteRecipeId) {
                   isSuccessful
                 }
               }
            """,
            variables: [
                "deleteRecipeId": id
            ]
        )
        let response: GraphQlResponse = await HttpClient.shared.queryAsync(request)
        
        return response.errors == nil
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
