//
//  Store.swift
//  Rater
//
//  Created by Александр Семенов on 26.11.2023.
//

import Foundation
import JWTDecode

struct Store {
    
    static let shared = Store()
    private init() {}
    func saveTokenIntoStorage(_ token: String) throws {
        UserDefaults.standard.set(token, forKey: "jwt-token")
        
    }
    func getTokenFromStorage() throws -> String {
        let token = UserDefaults.standard.string(forKey: "jwt-token")
        if token != nil {
            return token!
        } else {
            throw KeyStoreError.unableToGetData
        }
    }
    
    func deleteTokenFromStorage() {
        UserDefaults.standard.removeObject(forKey: "jwt-token")
    }
    
    func getUserIdFromToken(token: String) throws -> Int {
        let decodedToken = try decode(jwt: token)
        if let id = decodedToken["account_id"].integer {
            print("id: ", id)
            return id
        } else {
            print("Cannot get id")
            throw KeyStoreError.unableToGetData
        }
    }
    func ifToken() -> Bool {
        let token = UserDefaults.standard.string(forKey: "jwt-token")
        if token != nil {
            return true
        }
        return false
    }
}
