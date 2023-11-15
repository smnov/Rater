//
//  User.swift
//  Rater
//
//  Created by Александр Семенов on 15.11.2023.
//

struct User: Identifiable {
    var id: ObjectIdentifier?
    var username: String
    var email: String
    var password: String
}

struct UserLogin {
    var username: String
    var password: String
}
