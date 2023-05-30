//
//  GraphQlRequest.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 5/13/23.
//

import Foundation

class GraphQlRequest {
    
    let query: String
    
    let variables: [String: Any]
    
    init(query: String, variables: [String: Any]) {
        self.query = query;
        self.variables = variables;
    }
}
