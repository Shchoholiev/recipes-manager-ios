//
//  PagginationWrapper.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 12/6/22.
//

import Foundation

class PaginationWrapper<T : Decodable> : Decodable {
    
    let pagesCount: Int
    
    let items: [T]
    
    init(pagesCount: Int, items: [T]) {
        self.pagesCount = pagesCount
        self.items = items
    }
}
