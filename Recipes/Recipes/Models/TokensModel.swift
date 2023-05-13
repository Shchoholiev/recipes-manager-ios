//
//  TokensModel.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 5/13/23.
//

import Foundation

class TokensModel: Codable {
    
    var accessToken: String? = nil
    
    var refreshToken: String? = nil
    
    init(accessToken: String?, refreshToken: String?) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
