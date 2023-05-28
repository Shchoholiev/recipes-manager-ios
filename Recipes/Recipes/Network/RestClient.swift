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
    
    func postAsync<TIn: Encodable, TOut: Decodable>(_ path: String, _ data: TIn) async throws -> TOut {
        return try await sendAsync(path, data, .post)
    }
    
    func postAsync<TOut: Decodable>(_ path: String, _ formData: Data, _ contentType: String) async throws -> TOut {
        return try await sendAsync(path, formData, contentType, .post)
    }
    
    func putAsync<TIn: Encodable, TOut: Decodable>(_ path: String, _ data: TIn) async throws -> TOut {
        return try await sendAsync(path, data, .put)
    }
    
    private enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
    }
    
    private func sendAsync<TIn: Encodable, TOut: Decodable>(_ path: String, _ data: TIn, _ httpMethod: HttpMethod) async throws -> TOut {
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(data)
            
            var request = URLRequest(url: apiUrl.appendingPathComponent(path))
            request.httpMethod = httpMethod.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let jwt = accessToken {
                request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
            }
            request.httpBody = jsonData
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            let object = try decoder.decode(TOut.self, from: data)
            
            return object
        } catch {
            print(error)
            throw error
        }
    }

    private func sendAsync<TOut: Decodable>(_ path: String, _ formData: Data, _ contentType: String, _ httpMethod: HttpMethod) async throws -> TOut {
        do {
            var request = URLRequest(url: apiUrl.appendingPathComponent(path))
            request.httpMethod = httpMethod.rawValue
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
            if let jwt = accessToken {
                request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
            }
            request.httpBody = formData
            
            let (jsonData, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            let object = try decoder.decode(TOut.self, from: jsonData)
            
            return object
        } catch {
            print(error)
            throw error
        }
    }
}
