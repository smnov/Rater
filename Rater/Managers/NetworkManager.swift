//
//  NetworkManager.swift
//  Rater
//
//  Created by Александр Семенов on 16.11.2023.
//

import Foundation

extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}

class MockManager {
    let shared = MockManager()
    var photos: [Photo]
    private init() {
        self.photos = []
    }
}

struct LoginRequest: Codable {
    var name: String
    var password: String
}

struct LoginResponse: Codable {
    var token: String
}

struct Token {
    let token: String
}


class NetworkManager {
    
    static let shared = NetworkManager()
    private init() {}
    
    func login(name: String, password: String) async throws -> Void {
        
        guard let loginURL = URL(string: baseURL + "login") else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: loginURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let loginRequest = LoginRequest(name: name, password: password)
        let encoder = JSONEncoder()
        
        guard let data = try? encoder.encode(loginRequest) else {
            throw NetworkError.invalidData
        }
        
        request.httpBody = data
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let responseArray = try JSONDecoder().decode([LoginResponse].self, from: data)
            let firstElement = responseArray.first
            let token = firstElement?.token
            try Store.shared.saveTokenIntoStorage(token!)
        } catch {
            throw NetworkError.invalidCredentials
        }
    }
}

