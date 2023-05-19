//
//  PagedList.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 5/18/23.
//

import Foundation

class PagedList<T : Decodable> : Decodable {
    
    let totalPages: Int
    
    let items: [T]
    
    init(totalPages: Int, items: [T]) {
        self.totalPages = totalPages
        self.items = items
    }
}
