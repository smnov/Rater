//
//  Constants.swift
//  Rater
//
//  Created by Александр Семенов on 28.11.2023.
//

import Foundation

let baseURL = "http://localhost:8000/"
let imageURL = "http://localhost:8000/account/profile/files/image/"
let randomPhotoURL = "http://localhost:8000/files/random"
let rateURL = "http://localhost:8000/files/"

func getStatURL(id: Int) -> String {
    return baseURL + "profile/files/\(id)/stat"
}
