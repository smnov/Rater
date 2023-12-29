//
//  Alert.swift
//  Appetizers
//
//  Created by Александр Семенов on 09.11.2023.
//

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: Text
    let message: Text
    let dismissButton: Alert.Button
}

struct AlertContext {
    
    static let invalidData = AlertItem(title: Text("Server Error"), message: Text("The data received from the server is invalid"), dismissButton: .default(Text("OK")))
    
    static let invalidResponse = AlertItem(title: Text("Server Error"), message: Text("Invalid response from the server"), dismissButton: .default(Text("OK")))
    
    static let invalidURL = AlertItem(title: Text("Server Error"), message: Text("There was an issue with URL"), dismissButton: .default(Text("OK")))
    
    static let unableToComplete = AlertItem(title: Text("Server Error"), message: Text("Unable to complete your request"), dismissButton: .default(Text("OK")))
    
    static let invalidEmail = AlertItem(title: Text("Invalid email"), message: Text("Please provide correct email"), dismissButton: .default(Text("OK")))
    
    static let incompleteForm = AlertItem(title: Text("Form incompleted"), message: Text("Please complete the form"), dismissButton: .default(Text("OK")))
    
    static let invalidUsernameOrPassword = AlertItem(title: Text("Username or password is invalid"), message: Text("Please try again"), dismissButton: .default(Text("OK")))
    
    
}
