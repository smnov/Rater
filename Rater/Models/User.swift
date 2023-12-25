//
//  User.swift
//  Rater
//
//  Created by Александр Семенов on 15.11.2023.
//

struct User: Codable {
    let username: String
    let email: String
    let password: String
}

struct Profile: Codable {
    var id: Int = 0
    var name: String = "alex"
    var email: String = "alex"
    var created_at: String = "123"
}

struct UserRegister: Codable {
    var name: String
    var email: String
    var password1: String
    var password2: String
}
