//
//  ProfileRoute.swift
//  Rater
//
//  Created by Александр Семенов on 28.11.2023.
//

import Foundation
import UIKit

struct ProfileResponse: Codable {
    let profile: Profile
}

struct ProfileRoute {
    
    func loadProfile() async throws -> Profile {
        guard let profileURL = URL(string: baseURL + "account/profile") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: profileURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let token = try Store.shared.getTokenFromStorage()
            request.setValue(token, forHTTPHeaderField: "jwt-token")
        } catch let error {
            throw error
        }
        let (data, _) = try await URLSession.shared.data(for: request)
        let decodedResponse = try JSONDecoder().decode([Profile].self, from: data)
        return decodedResponse[0]
    }
    
    func loadProfilePhotos() async throws -> [Photo] {
        guard let photosURL = URL(string: baseURL + "account/profile/files") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: photosURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let token = try Store.shared.getTokenFromStorage()
            request.setValue(token, forHTTPHeaderField: "jwt-token")
        } catch let error {
            throw error
        }
        let (data, _) = try await URLSession.shared.data(for: request)
        guard let decodedResponse = try? JSONDecoder().decode([[Photo]].self, from: data) else {
            return [Photo(id: 1, url: "qwe")]
        }
        return decodedResponse[0]
    }
    
    func getImage(urlString: String, completed: @escaping(UIImage?) -> Void ) {
        guard let url = URL(string: urlString) else {
        completed(nil)
        return
    }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            
            guard let data, let image = UIImage(data: data) else {
                completed(nil)
                return
            }
            
            completed(image)
        }
        
        task.resume()
    }
    
    func uploadPhoto(image: UIImage) -> Result<Photo,Error> {
        guard let url = URL(string: uploadURL) else {
            return .failure(NetworkError.invalidURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data, boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        if let imageData = image.jpegData(compressionQuality: 0.5) {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"file\"; filename=\"photo.jpg\"\r\n")
                body.append("Content-Type: image/jpeg\r\n\r\n")
                body.append(imageData)
                body.append("\r\n")
            }

            body.append("--\(boundary)--\r\n")

            request.httpBody = body


            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(error)
                    return
                }


                completion(nil)
    }
}
