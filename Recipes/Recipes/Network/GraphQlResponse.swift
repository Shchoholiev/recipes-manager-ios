//
//  GraphQlResponse.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 5/13/23.
//

import Foundation

class GraphQlResponse {
    
    let data: [String: Any]?
    
    let errors: [[String: Any]]?
    
    init(data: [String : Any]?, errors: [[String : Any]]?) {
        self.data = data
        self.errors = errors
    }
}
