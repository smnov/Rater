//
//  Constants.swift
//  Rater
//
//  Created by Александр Семенов on 28.11.2023.
//

import Foundation

let baseURL = "http://localhost:8000/"
let uploadURL = "http://localhost:8000/upload"
let imageURL = "http://localhost:8000/account/profile/files/image/"
let randomPhotoURL = "http://localhost:8000/files/random"
let rateURL = "http://localhost:8000/files/"


func getStatURL(id: Int) -> String {
    return baseURL + "account/profile/files/\(id)/stat"
}

func getFileURLById(id: Int) -> String {
    return baseURL + "account/profile/files/\(id)"
}

func getRegisterURL() -> String {
    return baseURL + "account"
}
