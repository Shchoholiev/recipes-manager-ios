//
//  AuthService.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 5/29/23.
//

import Foundation

class AuthSerice {
    
    let jwtService = JwtTokensService()
    
    func login(_ user: LoginModel) async -> Bool {
        let request = GraphQlRequest(
            query: """
               mutation Login($login: LoginModelInput!) {
                 login(login: $login) {
                   accessToken
                   refreshToken
                 }
               }
            """,
            variables: [
                "login": [
                    "email": user.email,
                    "phone": user.phone,
                    "password": user.password
                ]
            ]
        )
        
        let result: GraphQlGenericResponse<TokensModel> = await HttpClient.shared.queryAsync(request, propertyName: "login")
        if let tokens = result.data {
            jwtService.storeTokensInKeychain(tokens: tokens)
            return true
        }
        
        return false
    }
    
    func loginAsGuest() {
        jwtService.clearTokensInKeychain()
    }
}
