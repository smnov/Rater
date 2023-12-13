//
//  LoginViewModel.swift
//  Rater
//
//  Created by Александр Семенов on 16.11.2023.
//

import Foundation

extension LoginView {
    @MainActor class ViewModel: ObservableObject {
        
        @Published var isLoggedIn: Bool = false
        @Published var showError = false
        
        
        
        func login(username: String, password: String) async throws {
            do {
                try await NetworkManager.shared.login(name: username, password: password)
            } catch let error {
                throw error
            }
        }
    }
}
