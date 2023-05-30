//
//  GraphQlGenericResponse.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 5/13/23.
//

import Foundation

class GraphQlGenericResponse<T: Decodable> {
    
    let data: T?
    
    let errors: [[String: Any]]?
    
    init(data: T?, errors: [[String : Any]]?) {
        self.data = data
        self.errors = errors
    }
}
