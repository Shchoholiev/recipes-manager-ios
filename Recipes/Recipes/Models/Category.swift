//
//  Category.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 5/18/23.
//

import Foundation

class Category : Codable {
    
    let id: String
    
    let name: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
