//
//  GraphQlClient.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 5/13/23.
//

import Foundation

class GraphQlClient {
    
    let graphQlUrl: URL
    
    var accessToken: String? = nil
    
    init(_ baseUrl: String) {
        graphQlUrl = URL(string: "\(baseUrl)graphql/")!
    }
    
    func queryAsync(_ graphQlRequest: GraphQlRequest) async -> GraphQlResponse {
        var errors: [[String: Any]]? = []
        
        do {
            let body: [String: Any] = [
                "query": graphQlRequest.query,
                "variables": graphQlRequest.variables
            ]

            let requestData = try JSONSerialization.data(withJSONObject: body, options: [])
            
            var request = URLRequest(url: graphQlUrl)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let jwt = accessToken {
                request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
            }
            request.httpBody = requestData
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            if let jsonDictionary = jsonObject as? [String: Any] {
                let data = jsonDictionary["data"] as? [String: Any]
                errors = jsonDictionary["errors"] as? [[String: Any]]
                let response = GraphQlResponse(data: data, errors: errors)
                
                return response
            }
        } catch {
            errors?.append(["error": error])
        }
        
        return GraphQlResponse(data: nil, errors: errors)
    }
    
    func queryAsync<T: Decodable>(_ graphQlRequest: GraphQlRequest, propertyName: String) async -> GraphQlGenericResponse<T> {
        var errors: [[String: Any]]? = []
        
        do {
            let body: [String: Any] = [
                "query": graphQlRequest.query,
                "variables": graphQlRequest.variables
            ]

            let requestData = try JSONSerialization.data(withJSONObject: body, options: [])
            
            var request = URLRequest(url: graphQlUrl)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let jwt = accessToken {
                request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
            }
            request.httpBody = requestData
            
            let (responseData, _) = try await URLSession.shared.data(for: request)
            let jsonObject = try JSONSerialization.jsonObject(with: responseData, options: [])
            if let jsonDictionary = jsonObject as? [String: Any] {
                let data = jsonDictionary["data"] as? [String: Any]
                errors = jsonDictionary["errors"] as? [[String: Any]]
                
                if let safeData = data {
                    let dictionary = safeData[propertyName];
                    if let objectDictionary = dictionary {
                        let jsonData = try JSONSerialization.data(withJSONObject: objectDictionary, options: [])
                        let decoder = JSONDecoder()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                        decoder.dateDecodingStrategy = .formatted(dateFormatter)
                        let object = try decoder.decode(T.self, from: jsonData)
                        let response = GraphQlGenericResponse<T>(data: object, errors: errors)
                        
                        return response
                    }
                }  
            }
        } catch {
            print(error)
            errors?.append(["error": error])
        }
        
        return GraphQlGenericResponse<T>(data: nil, errors: errors)
    }
}
