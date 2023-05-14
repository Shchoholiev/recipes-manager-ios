//
//  RestClient.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 5/13/23.
//

import Foundation

class RestClient {
    
    let apiUrl: URL
    
    var accessToken: String? = nil
    
    init(_ baseUrl: String) {
        apiUrl = URL(string: "\(baseUrl)api/")!
    }
    
    func postAsync<TIn: Encodable, TOut: Decodable>(_ data: TIn) async -> TOut? {
        return await sendAsync(data, .post)
    }
    
    func putAsync<TIn: Encodable, TOut: Decodable>(_ data: TIn) async -> TOut? {
        return await sendAsync(data, .put)
    }
    
    private enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
    }
    
    private func sendAsync<TIn: Encodable, TOut: Decodable>(_ data: TIn, _ httpMethod: HttpMethod) async -> TOut? {
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(data)
            
            var request = URLRequest(url: apiUrl)
            request.httpMethod = httpMethod.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let jwt = accessToken {
                request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
            }
            request.httpBody = jsonData
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let object = try JSONDecoder().decode(TOut.self, from: data)
            
            return object
        } catch {
            print(error)
        }
        
        return nil
    }
}
