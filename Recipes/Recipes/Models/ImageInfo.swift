//
//  ImageInfo.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 12/31/22.
//

import Foundation

class ImageInfo: Decodable {
    let link: String?
    
    init(link: String) {
        self.link = link
    }
}
