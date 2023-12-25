//
//  RegisterRoute.swift
//  Rater
//
//  Created by Александр Семенов on 24.12.2023.
//

import Foundation

struct RegisterRoute {
    func register(userData: UserRegister, completed: @escaping (Result<Profile,Error>) -> Void) {
        guard let url = URL(string: getRegisterURL()) else {
            return completed(.failure(NetworkError.invalidURL))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let data = try? JSONEncoder().encode(userData) else {
            return completed(.failure(NetworkError.invalidData))
        }
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error ) in
            if error != nil {
                completed(.failure(NetworkError.invalidResponse))
            }
                switch (response as? HTTPURLResponse)?.statusCode {
                case 400:
                    completed(.failure(NetworkError.userAlreadyExist))
                case 200:
                    if let data = data {
                        do {
                            let decodedData = try JSONDecoder().decode([Profile].self, from: data)
                            completed(.success(decodedData[0]))
                        } catch {
                            completed(.failure(NetworkError.decodingError))
                        }
                    } else {
                        completed(.failure(NetworkError.invalidData))
                    }
                default:
                    print("default")
                    completed(.failure(NetworkError.unknownError))
                }
            }
            task.resume()
        }
        
    }
