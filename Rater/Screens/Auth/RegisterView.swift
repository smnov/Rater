//
//  SignUpView.swift
//  Rater
//
//  Created by Александр Семенов on 15.11.2023.
//

import SwiftUI

struct SignUpView: View {
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var password2 = ""
    @State private var wrongPassword = 0
    @State private var wrongUsername = 0
    @State private var isLoggedIn = false
    @StateObject private var viewmodel = AuthViewModel()
    
    var body: some View {
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
                
                Text("Sign Up")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                TextField("Username", text: $username)
                    .padding()
                    .textInputAutocapitalization(.never)
                    .frame(width: 300, height: 50)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(10)
                    .border(.red, width: CGFloat(wrongUsername))
                TextField("Email", text: $email)
                    .padding()
                    .textInputAutocapitalization(.never)
                    .frame(width: 300, height: 50)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(10)
                    .border(.red, width: CGFloat(wrongUsername))
                SecureField("Password", text: $password)
                    .padding()
                    .textInputAutocapitalization(.never)
                    .frame(width: 300, height: 50)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(10)
                    .border(.red, width: CGFloat(wrongPassword))
                SecureField("Repeat password", text: $password2)
                    .padding()
                    .textInputAutocapitalization(.never)
                    .frame(width: 300, height: 50)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(10)
                    .border(.red, width: CGFloat(wrongPassword))
                Button {
                    viewmodel.register(username, email, password, password2)
                } label: {
                    Text("Register")
                }
                .foregroundColor(.white)
                .frame(width: 300, height: 50)
                .background(Color.red)
                .cornerRadius(10)
                .padding()
            }
        }
    }
}

#Preview {
    SignUpView()
}
