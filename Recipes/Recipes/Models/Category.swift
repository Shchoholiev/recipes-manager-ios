//
//  Category.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 12/6/22.
//

import Foundation

class Category : Codable {
    
    let id: Int
    
    let name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}
