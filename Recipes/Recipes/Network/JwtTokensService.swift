//
//  JwtTokens.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 5/13/23.
//

import Foundation
import JWTDecode

class JwtTokensService {
    
    let accessTokenIdentifier = "accessToken"
    
    let refreshTokenIdentifier = "refreshToken"
    
    func storeTokensInKeychain(tokens: TokensModel) {
        let accessTokenQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: refreshTokenIdentifier,
            kSecValueData as String: tokens.refreshToken.data(using: .utf8)!
        ]
        
        let refreshTokenQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: accessTokenIdentifier,
            kSecValueData as String: tokens.accessToken.data(using: .utf8)!,
        ]
        
        let accessStatus = SecItemAdd(accessTokenQuery as CFDictionary, nil)
        if accessStatus != errSecSuccess {
            print("Error storing Access Token in Keychain")
        }

        let refreshStatus = SecItemAdd(refreshTokenQuery as CFDictionary, nil)
        if refreshStatus != errSecSuccess {
            print("Error storing Refresh Token in Keychain")
        }
    }
    
    func isExpired() -> Bool {
        let jwtTokens = getTokensFromKeychain();
        if let tokens = jwtTokens {
            do {
                let jwt = try decode(jwt: tokens.accessToken)
                let expirationDate = jwt.expiresAt
                let currentDate = getCurrentUTCDate()

                return expirationDate != nil && currentDate > expirationDate!
            } catch {
                print("Error decoding JWT token: \(error)")
            }
        }
        
        return true
    }
    
    private func getCurrentUTCDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let utcDateString = dateFormatter.string(from: Date())
        return dateFormatter.date(from: utcDateString)!
    }
    
    private func getTokensFromKeychain() -> TokensModel? {
        let accessTokenValue = self.getTokenFromKeychain(accessTokenIdentifier);
        let refreshTokenValue = self.getTokenFromKeychain(refreshTokenIdentifier);
        
        if let accessToken = accessTokenValue,
           let refreshToken = refreshTokenValue {
            return TokensModel(accessToken: accessToken, refreshToken: refreshToken)
        }
        
        return nil
    }
    
    private func getTokenFromKeychain(_ identifier: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: identifier,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
            let data = result as? Data,
            let value = String(data: data, encoding: .utf8) {
            
            return value
        } else {
            return nil
        }
    }
}
