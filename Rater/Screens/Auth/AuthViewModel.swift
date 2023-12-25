//
//  LoginViewModel.swift
//  Rater
//
//  Created by Александр Семенов on 16.11.2023.
//

import Foundation

@MainActor class AuthViewModel: ObservableObject {
    
    @Published var isLoggedIn: Bool = false
    @Published var showError = false
    
    
    
    func login(username: String, password: String) {
        LoginRoute.shared.login(name: username, password: password) { result in
            switch result {
            case .success(let response):
                return
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func register(_ username: String, _ email: String, _ password1: String, _ password2: String) {
        let route = RegisterRoute()
        let userData = UserRegister(name: username, email: email, password1: password1, password2: password2)
        route.register(userData: userData) { result in
            switch result {
            case .success(let user):
                self.login(username: user.name, password: userData.password1)
            case .failure(let error):
                print(error)
            }
            
        }
    }
}

