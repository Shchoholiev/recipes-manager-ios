//
//  ImageUploadStates.swift
//  Recipes
//
//  Created by Vitalii Krasnorutskyi on 15.05.23.
//

import Foundation

enum ImageUploadStates : Int, Codable {
    case Started = 0
    case Uploaded = 1
    case Failed = 2
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(Int.self)
        
        switch rawValue {
        case 0:
            self = .Started
        case 1:
            self = .Uploaded
        case 2:
            self = .Failed
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid status value")
        }
    }
}
