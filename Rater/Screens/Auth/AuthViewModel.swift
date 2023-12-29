//
//  LoginViewModel.swift
//  Rater
//
//  Created by Александр Семенов on 16.11.2023.
//

import Foundation

@MainActor class AuthViewModel: ObservableObject {
    
    @Published var isLoggedIn: Bool = false
    @Published var alertItem: AlertItem?
    
    
    
    func login(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        LoginRoute.shared.login(name: username, password: password) { result in
            switch result {
            case .success:
                self.isLoggedIn = true
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func register(_ username: String, _ email: String, _ password1: String, _ password2: String) {
        let route = RegisterRoute()
        let userData = UserRegister(name: username, email: email, password1: password1, password2: password2)
        route.register(userData: userData) { result in
            switch result {
            case .success(let user):
                self.login(username: user.name, password: userData.password1) { loginResult in
                    switch loginResult {
                    case .success:
                        self.isLoggedIn = true
                    case .failure(let loginError):
                        print(loginError)
                    }
                }
            case .failure(let error):
                print(error)
            }
            
        }
    }
}

