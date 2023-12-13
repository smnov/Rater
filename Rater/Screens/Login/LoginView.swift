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
    
    @StateObject var viewmodel = LoginView.ViewModel()
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
                            do {
                                try await viewmodel.login(username: username, password: password)
                                state.isLoggedIn = true
                            } catch let error {
                                throw error
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
        }
        
        .navigationBarHidden(true)
    }
}

#Preview {
    LoginView()
}
