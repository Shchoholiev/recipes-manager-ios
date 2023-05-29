//
//  CategoriesService.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 12/6/22.
//

import Foundation

class CategoriesService {
    
    func getPageAsync(pageNumber: Int = 1, pageSize: Int = 10) async -> PagedList<Category>? {
        let request = GraphQlRequest(
            query: """
               query Categories($pageNumber: Int!, $pageSize: Int!) {
                 categories(pageNumber: $pageNumber, pageSize: $pageSize) {
                   items {
                     id
                     name
                   }
                   totalPages
                 }
               }
            """,
            variables: [
                "pageNumber": pageNumber,
                "pageSize": pageSize
            ]
        )
        let response: GraphQlGenericResponse<PagedList<Category>> = await HttpClient.shared.queryAsync(request, propertyName: "categories")
    
        return response.data;
    }
    
//    func getPageAsync(pageNumber: Int, filter: String) async -> PaginationWrapper<CategoryOld>? {
//        let encodedFilter = filter.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlHostAllowed)
//        if let safeFilter = encodedFilter {
//            let url = URL(string: "\(baseUrl)/page/\(pageNumber)/\(safeFilter)")
//            if let safeUrl = url {
//                do {
//                    let (data, _) = try await URLSession.shared.data(from: safeUrl)
//                    let categories = try JSONDecoder().decode(PaginationWrapper<CategoryOld>.self, from: data)
//                    return categories
//                } catch {
//                    print(error)
//                }
//            }
//        }
//
//        return nil
//    }
    
    func createCategory(_ category: Category) async -> Category? {
        let request = GraphQlRequest(
            query: """
               mutation AddCategory($category: CategoryInput!) {
                 addCategory(category: $category) {
                   id
                   name
                 }
               }
            """,
            variables: [
                "category": [
                    "name": category.name
                ]
            ]
        )
        let response: GraphQlGenericResponse<Category> = await HttpClient.shared.queryAsync(request, propertyName: "addCategory")
    
        return response.data;
    }
    
//    func deleteAsync(id: Int) async -> Bool {
//        let url = URL(string: "\(baseUrl)/\(id)")
//        if let safeUrl = url {
//            do {
//                var request = URLRequest(url: safeUrl)
//                request.httpMethod = "DELETE"
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
}
