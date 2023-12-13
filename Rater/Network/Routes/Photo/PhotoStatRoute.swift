//
//  PhotoStatRoute.swift
//  Rater
//
//  Created by Александр Семенов on 13.12.2023.
//

import Foundation

struct PhotoStatRoute {
    func getPhotoStat(id: Int) async throws -> Result<PhotoRating, Error> {
        guard let url = URL(string: getStatURL(id: id)) else {
            return .failure(NetworkError.invalidURL)
        }
        
        var request = URLRequest(url: url)
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
        let decodedResponse = try JSONDecoder().decode([PhotoRating].self, from: data)
        guard let photoRating = decodedResponse.first else {
            return .failure(NetworkError.emptyResult)
        }
        return .success(photoRating)
    }
}
