//
//  PhotoRateRoute.swift
//  Rater
//
//  Created by Александр Семенов on 03.12.2023.
//

import Foundation
import JWTDecode

struct PhotoRateRoute {
    func getRandomPhoto() async throws -> Result<Photo,Error> {
        guard let photoURL = URL(string: randomPhotoURL) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: photoURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let token = try Store.shared.getTokenFromStorage()
            request.setValue(token, forHTTPHeaderField: "jwt-token")
        } catch {
            return .failure(KeyStoreError.unableToGetData)
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode ?? 0 == 200 else {
            return .failure(NetworkError.notFound)
            }
        let decodedResponse = try JSONDecoder().decode([Photo].self, from: data)
        guard let photo = decodedResponse.first else {
            return .failure(NetworkError.emptyResult)
        }
        return .success(photo)
    }
    
    func ratePhoto(_ photoRequest: PhotoRateRequest) async throws {
        guard let rateURL = URL(string: rateURL + "\(String(describing: photoRequest.file_id!))/rate") else {
            throw NetworkError.invalidURL
        }
        print(rateURL)
        var request = URLRequest(url: rateURL)
        var photoRequestWithId = photoRequest
        
        do {
            let token = try Store.shared.getTokenFromStorage()
            let userId = try? Store.shared.getUserIdFromToken(token: token)
            photoRequestWithId.addId(id: userId!)
            request.setValue(token, forHTTPHeaderField: "jwt-token")
        } catch let error {
            throw error
        }
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let fileId = photoRequestWithId.file_id, let accId = photoRequestWithId.account_id {
            request.httpBody = try JSONEncoder().encode(photoRequestWithId)
        } else {
            throw NetworkError.invalidCredentials
        }
        let (_, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode ?? 0 == 200 else {
            throw NetworkError.invalidResponse
            }
    }
    
    func deletePhoto(_ fileId: Int) async throws -> Error? {
        guard let url = URL(string: getFileURLById(id: fileId)) else {
            return NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        do {
            let token = try Store.shared.getTokenFromStorage()
            request.setValue(token, forHTTPHeaderField: "jwt-token")
        } catch {
            return KeyStoreError.unableToGetData
        }
        
        let (_, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        if statusCode != 200 {
            return NetworkError.invalidResponse
        }
        return nil
    }
}
