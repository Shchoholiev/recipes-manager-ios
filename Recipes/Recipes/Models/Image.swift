//
//  Image.swift
//  Recipes
//
//  Created by Vitalii Krasnorutskyi on 15.05.23.
//

class Image : Codable {
    var id: String?
    var originalPhotoGuid: String?
    var smallPhotoGuid: String?
    var `extension`: String?
    var md5Hash: String?
    var imageUploadState: ImageUploadStates?
    
    init(id: String, originalPhotoGuid: String, smallPhotoGuid: String, `extension`: String, md5Hash: String, imageUploadState: ImageUploadStates) {
        self.id = id
        self.originalPhotoGuid = originalPhotoGuid
        self.smallPhotoGuid = smallPhotoGuid
        self.`extension` = `extension`
        self.md5Hash = md5Hash
        self.imageUploadState = imageUploadState
    }
}
