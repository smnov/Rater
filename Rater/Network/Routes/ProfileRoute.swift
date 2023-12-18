//
//  ProfileRoute.swift
//  Rater
//
//  Created by Александр Семенов on 28.11.2023.
//

import Foundation
import UIKit
import SwiftUI

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
    
    func uploadPhoto(fileName: String, image: UIImage, completed: @escaping (Result<Photo,Error>) -> Void) {
        guard let url = URL(string: uploadURL) else {
            return completed(.failure(NetworkError.invalidData))
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            let token = try Store.shared.getTokenFromStorage()
            request.setValue(token, forHTTPHeaderField: "jwt-token")
        } catch {
            completed(.failure(KeyStoreError.unableToGetData))
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            // Handle error if unable to convert image to data
            return
        }
        
        let boundary = UUID().uuidString
        let clrf = "\r\n"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()
        body.append("--\(boundary)")
        body.append(clrf)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"")
        body.append(clrf)
        body.append("Content-Type: image/jpeg")
        body.append(clrf)
        body.append(clrf)
        body.append(imageData)
        body.append(clrf)
        body.append("--\(boundary)--")
        body.append(clrf)

        request.httpBody = body
        
        print("Request URL: \(request.url?.absoluteString ?? "")")
        print("HTTP Method: \(request.httpMethod ?? "")")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")

        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completed(.failure(NetworkError.invalidResponse))
            } else {
                guard (response as? HTTPURLResponse)?.statusCode ?? 0 == 200 else {
                    print((response as? HTTPURLResponse)!.statusCode)
                    completed(.failure(NetworkError.invalidResponseStatusCode))
                    return
                }
            }
        }
            task.resume()
        }
    }
