//
//  Photo.swift
//  Rater
//
//  Created by Александр Семенов on 16.11.2023.
//

struct Photo: Identifiable, Codable {
    var id: Int
    var url: String
}

struct PhotoRating: Codable {
    var attractiveness_rating: Float
    var smart_rating: Float
    var trustworthy_rating: Float
}

let samplePhoto = Photo(id: 0, url: "placeholder")


struct PhotoRateRequest: Codable {
    var account_id: Int?
    var file_id: Int?
    var attractiveness_rating: Float
    var smart_rating: Float
    var trustworthy_rating: Float
    
    mutating func addId(id: Int) {
        account_id = id
    }
}

struct PhotoGetRequest: Codable {
    var file_id: Int
}
