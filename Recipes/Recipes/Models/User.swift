//
//  User.swift
//  Recipes
//
//  Created by Vitalii Krasnorutskyi on 29.05.23.
//

import Foundation

class User : Codable {
    var id : String
    var name : String
    var phone : String?
    var email : String?
    
    init(id: String, name: String, phone: String?, email: String?) {
        self.id = id
        self.name = name
        self.phone = phone
        self.email = email
    }
}
