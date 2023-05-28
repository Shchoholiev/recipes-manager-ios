//
//  HttpClient.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 5/13/23.
//

import UIKit

class HttpClient {
    
    static let shared = HttpClient()
    
    private let baseUrl = "https://sh-recipes-manager-api-dev.azurewebsites.net/"
    
    private let graphQlClient: GraphQlClient
    
    private let restClient: RestClient
    
    private let jwtTokensService = JwtTokensService()
    
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
    
    private func checkAccessTokenAsync() async {
        if jwtTokensService.isExpired() {
            let tokensModel = await getTokensAsync()
            if let tokens = tokensModel {
                jwtTokensService.storeTokensInKeychain(tokens: tokens)
                graphQlClient.accessToken = tokens.accessToken
                restClient.accessToken = tokens.accessToken
            }
        } else {
            let tokensModel = jwtTokensService.getTokensFromKeychain()
            if let tokens = tokensModel {
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
}
