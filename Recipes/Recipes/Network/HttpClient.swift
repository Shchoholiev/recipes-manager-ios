//
//  HttpClient.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 5/13/23.
//

import UIKit
import EventSource

class HttpClient {
    
    static let shared = HttpClient()
    
    private let baseUrl = "https://sh-recipes-manager-api-dev.azurewebsites.net/"
    
    private let graphQlClient: GraphQlClient
    
    private let restClient: RestClient
    
    private let jwtTokensService = JwtTokensService()
    
    private var accessToken: String?
    
    init() {
        graphQlClient = GraphQlClient(baseUrl)
        restClient = RestClient(baseUrl)
    }
    
    func queryAsync(_ graphQlRequest: GraphQlRequest) async -> GraphQlResponse {
        await self.checkAccessTokenAsync()
        return await graphQlClient.queryAsync(graphQlRequest)
    }
    
    func queryAsync<T: Decodable>(_ graphQlRequest: GraphQlRequest, propertyName: String) async -> GraphQlGenericResponse<T> {
        await self.checkAccessTokenAsync()
        return await graphQlClient.queryAsync(graphQlRequest, propertyName: propertyName)
    }
    
    func postAsync<TIn: Encodable, TOut: Decodable>(_ path: String, _ data: TIn) async throws -> TOut {
        await self.checkAccessTokenAsync()
        return try await restClient.postAsync(path, data)
    }
    
    func postAsync<TOut: Decodable>(_ path: String, _ formData: Data, _ contentType: String) async throws -> TOut {
        await self.checkAccessTokenAsync()
        return try await restClient.postAsync(path, formData, contentType)
    }
    
    func putAsync<TIn: Encodable, TOut: Decodable>(_ path: String, _ data: TIn) async throws -> TOut {
        await self.checkAccessTokenAsync()
        return try await restClient.putAsync(path, data)
    }
    
    func readSSE<TIn: Encodable, TOut: Decodable>(_ path: String, _ httpMethod: HttpMethod, _ data: TIn) async throws -> AsyncStream<TOut> {
        await self.checkAccessTokenAsync()
        let stream = AsyncStream<TOut> { continuation in
            Task {
                if let url = URL(string: "\(baseUrl)\(path)") {
                    let jsonEncoder = JSONEncoder()
                    let jsonData = try jsonEncoder.encode(data)
                    
                    var request = URLRequest(url: url)
                    request.httpMethod = httpMethod.rawValue
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    if let jwt = accessToken {
                        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
                    }
                    request.httpBody = jsonData
                    let eventSource = EventSource(request: request, maxRetryCount: 0)
                    eventSource.connect()
                    
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .custom { keys in
                        let lastKey = keys.last!
                        let convertedKey = self.convertPascalToCamelCase(lastKey.stringValue)
                        return AnyCodingKey(stringValue: convertedKey)!
                    }
                    
                    for await event in eventSource.events {
                        switch event {
                        case .open:
//                            print("Connection was opened.")
                            break
                        case .error(let error):
//                            print("Received an error:", error.localizedDescription)
                            break
                        case .message(let message):
//                            print("Received a message:", message.data)
                            if let messageData = message.data, let jsonData = messageData.data(using: .utf8) {
                                let object = try decoder.decode(TOut.self, from: jsonData)
                                continuation.yield(object)
                            }
                        case .closed:
//                            print("Connection was closed.")
                            continuation.finish()
                            break
                        }
                    }
                    continuation.finish()
                }
            }
        }
        
        return stream
    }
    
    private func checkAccessTokenAsync() async {
        if jwtTokensService.isExpired() {
            let tokensModel = await getTokensAsync()
            if let tokens = tokensModel {
                jwtTokensService.storeTokensInKeychain(tokens: tokens)
                accessToken = tokens.accessToken
                graphQlClient.accessToken = tokens.accessToken
                restClient.accessToken = tokens.accessToken
            }
        } else {
            let tokensModel = jwtTokensService.getTokensFromKeychain()
            if let tokens = tokensModel {
                accessToken = tokens.accessToken
                graphQlClient.accessToken = tokens.accessToken
                restClient.accessToken = tokens.accessToken
            }
        }
    }
    
    private func getTokensAsync() async -> TokensModel? {
        let vendorIdentifier = self.getVendorIdentifier()
        if let vendorId = vendorIdentifier {
            let name = getDeviceName()
            let request = GraphQlRequest(
                query: """
                    mutation AccessAppleGuest($model: AccessAppleGuestModelInput!) {
                      accessAppleGuest(model: $model) {
                        accessToken
                        refreshToken
                      }
                    }
                """,
                variables: [
                    "model": [
                        "appleDeviceId": vendorId,
                        "name": name
                    ]
                ]
            )
            
            let response: GraphQlGenericResponse<TokensModel> = await graphQlClient.queryAsync(request, propertyName: "accessAppleGuest")
            if let tokens = response.data {
                return tokens
            }
        }
        
        return nil
    }
    
    private func getDeviceName() -> String {
        let device = UIDevice.current
        return device.name
    }

    private func getVendorIdentifier() -> String? {
        if let identifier = UIDevice.current.identifierForVendor?.uuidString {
            return identifier
        }
        return nil
    }
    
    private func convertPascalToCamelCase(_ pascalKey: String) -> String {
        let firstChar = pascalKey.prefix(1).lowercased()
        let otherChars = pascalKey.dropFirst()
        return "\(firstChar)\(otherChars)"
    }
    
    struct AnyCodingKey: CodingKey {
        let stringValue: String
        let intValue: Int?

        init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }

        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
    }
}
