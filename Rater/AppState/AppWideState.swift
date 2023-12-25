//
//  AppStateView.swift
//  Rater
//
//  Created by Александр Семенов on 27.11.2023.
//

import Foundation

class AppWideState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var token = Store.shared.ifToken()
}
