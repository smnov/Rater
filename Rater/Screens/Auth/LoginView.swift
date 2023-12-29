//
//  LoginView.swift
//  Rater
//
//  Created by Александр Семенов on 14.11.2023.
//

import SwiftUI

struct LoginView: View {
    
    @State private var username = ""
    @State private var password = ""
    @State private var wrongPassword = 0
    @State private var wrongUsername = 0
    
    @StateObject var viewmodel = AuthViewModel()
    @EnvironmentObject var state: AppWideState
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.red
                    .ignoresSafeArea()
                Circle()
                    .scale(1.7)
                    .foregroundColor(.white.opacity(0.15))
                Circle()
                    .scale(1.15)
                    .foregroundColor(.white)
                VStack {
                    
                    Text("Login")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                    TextField("Username", text: $username)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                        .textInputAutocapitalization(.never)
                        .border(.red, width: CGFloat(wrongUsername))
                    SecureField("Password", text: $password)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                        .textInputAutocapitalization(.never)
                        .border(.red, width: CGFloat(wrongPassword))
                    
                    Button {
                        Task {
                            guard !username.isEmpty, !password.isEmpty else {
                                viewmodel.alertItem = AlertItem(title: Text("Error"), message: Text("Username and password cannot be empty"), dismissButton: .default(Text("OK")))
                                return
                            }

                            viewmodel.login(username: username, password: password) { result in
                                switch result {
                                case .success:
                                    state.isLoggedIn = true
                                case .failure(let error):
                                    switch error {
                                    case NetworkError.invalidUsernameOrPassword:
                                        viewmodel.alertItem = AlertContext.invalidUsernameOrPassword
                                    case NetworkError.invalidURL:
                                        viewmodel.alertItem = AlertContext.invalidURL
                                    case NetworkError.invalidResponse:
                                        viewmodel.alertItem = AlertContext.invalidResponse
                                    case NetworkError.decodingError:
                                        viewmodel.alertItem = AlertContext.incompleteForm
                                    default:
                                        viewmodel.alertItem = AlertContext.unableToComplete
                                    }
                                }
                            }
                        }
                    } label: {
                        Text("Login")
                    }
                    
                    .foregroundColor(.white)
                    .frame(width: 300, height: 50)
                    .background(Color.red)
                    .cornerRadius(10)
                    .padding()
                    Text("Don't have an accound?")
                    NavigationLink("Sign Up", destination: SignUpView())
                }
            }
            .alert(item: $viewmodel.alertItem) { alert in
                Alert(title: alert.message, dismissButton: alert.dismissButton)
        }
        
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    LoginView()
}
