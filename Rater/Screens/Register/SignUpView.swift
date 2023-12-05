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
                    .frame(width: 300, height: 50)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(10)
                    .border(.red, width: CGFloat(wrongUsername))
                TextField("Email", text: $email)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(10)
                    .border(.red, width: CGFloat(wrongUsername))
                TextField("Password", text: $password)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(10)
                    .border(.red, width: CGFloat(wrongPassword))
                TextField("Repeat password", text: $password2)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(10)
                    .border(.red, width: CGFloat(wrongPassword))
                Button {
                    
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
