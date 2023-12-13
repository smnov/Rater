//
//  Errors.swift
//  Rater
//
//  Created by Александр Семенов on 26.11.2023.
//

import Foundation

enum KeyStoreError: Error {
    case unableToStoreData
    case unableToGetData
}

extension KeyStoreError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unableToGetData:
            return NSLocalizedString("No token in store", comment: "")
        case .unableToStoreData:
            return NSLocalizedString("Unable to store data", comment: "")
        }
    }
}

enum NetworkError: Error {
    case unableToComplete
    case invalidData
    case notFound
    case invalidURL
    case invalidResponse
    case invalidCredentials
    case emptyResult
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return NSLocalizedString("Data is invalid", comment: "")
        case .notFound:
            return NSLocalizedString("404 Not Found", comment: "")
        case .unableToComplete:
            return NSLocalizedString("Error", comment: "")
        case .invalidURL:
            return NSLocalizedString("URL is invalid", comment: "")
        case .invalidCredentials:
            return NSLocalizedString("Credentials are invalid", comment: "")
        default:
            return NSLocalizedString("default", comment: "")
        
        }
    
        
    }
}
