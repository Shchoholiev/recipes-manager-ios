//
//  RecipesSearchTypes.swift
//  Recipes
//
//  Created by Vitalii Krasnorutskyi on 15.05.23.
//

import Foundation

enum RecipesSearchTypes: Int {
    case PERSONAL
    case PUBLIC
    case SUBSCRIBED
    case SAVED
    
    var name: String {
        return String(describing: self)
    }
}
