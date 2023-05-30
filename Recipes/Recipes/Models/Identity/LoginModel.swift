//
//  LoginModel.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 5/29/23.
//

import Foundation

class LoginModel: Codable {
    public var email: String?
    public var phone: String?
    public var password: String

    public init(email: String? = nil, phone: String? = nil, password: String) {
        self.email = email
        self.phone = phone
        self.password = password
    }
}
