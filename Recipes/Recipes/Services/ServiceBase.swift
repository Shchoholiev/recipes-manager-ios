//
//  ServiceBase.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 12/6/22.
//

import Foundation

class ServiceBase {
    
    let baseUrl: String
    
    init(url: String) {
        baseUrl = "https://sh-recipes-api.azurewebsites.net/api\(url)"
    }
}
