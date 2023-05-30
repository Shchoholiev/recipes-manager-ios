//
//  HelpersService.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 12/11/22.
//

import Foundation

class HelpersService {
    
    func downloadImage(from link: String) async -> Data? {
        let url = URL(string: link)
        if let safeUrl = url {
            do {
                let (data, _) = try await URLSession.shared.data(from: safeUrl)
                return data
            } catch {
                print(error)
            }
        }
        
        return nil
    }
    
    func uploadImage(imageData: Data?, blobContainer: String) async -> String? {
        let url = URL(string: "https://shch-recipes-api.azurewebsites.net/api/cloud-storage/upload/\(blobContainer)")
        if let safeUrl = url, let safeImageData = imageData {
            do {
                let boundary = UUID().uuidString
                let filename = UUID().uuidString
                var body = Data()
                body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename).jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(safeImageData)
                body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
                
                var request = URLRequest(url: safeUrl)
                request.httpMethod = "POST"
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                request.httpBody = body
                
                let (data, _) = try await URLSession.shared.data(for: request)
                let imageInfo = try JSONDecoder().decode(ImageInfo.self, from: data)
                return imageInfo.link
            } catch {
                print(error)
            }
        }
        
        return nil
    }
}
