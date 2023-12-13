//
//  experiment.swift
//  Rater
//
//  Created by Александр Семенов on 15.11.2023.
//

var admin = User(username: "admin", email: "admin@admin.com", password: "1234")
var adminLogin = UserLogin(username: "admin", password: "1234")

struct MockData {
    var users: [UserLogin] = [adminLogin]
}

