//
//  CategoriesService.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 12/6/22.
//

import Foundation

class CategoriesService: ServiceBase {
    
    init() {
        super.init(url: "/categories")
    }
    
    func getPageAsync(pageNumber: Int) async -> PaginationWrapper<Category>? {
        let url = URL(string: "\(baseUrl)/page/\(pageNumber)")
        if let safeUrl = url {
            do {
                let (data, _) = try await URLSession.shared.data(from: safeUrl)
                let categories = try JSONDecoder().decode(PaginationWrapper<Category>.self, from: data)
                return categories
            } catch {
                print(error)
            }
        }
        
        return nil
    }
    
    func getPageAsync(pageNumber: Int, filter: String) async -> PaginationWrapper<Category>? {
        let encodedFilter = filter.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlHostAllowed)
        if let safeFilter = encodedFilter {
            let url = URL(string: "\(baseUrl)/page/\(pageNumber)/\(safeFilter)")
            if let safeUrl = url {
                do {
                    let (data, _) = try await URLSession.shared.data(from: safeUrl)
                    let categories = try JSONDecoder().decode(PaginationWrapper<Category>.self, from: data)
                    return categories
                } catch {
                    print(error)
                }
            }
        }
        
        return nil
    }
    
    func createCategory(_ category: Category) async -> Int {
        let url = URL(string: baseUrl)
        if let safeUrl = url {
            do {
                let jsonEncoder = JSONEncoder()
                let jsonData = try jsonEncoder.encode(category)
                
                var request = URLRequest(url: safeUrl)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                
                let (data, _) = try await URLSession.shared.data(for: request)
                let str = String(data: data, encoding: .utf8)
                if let response = str, let id = Int(response) {
                    return id
                }
            } catch {
                print(error)
            }
        }
        
        return 0
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
}
