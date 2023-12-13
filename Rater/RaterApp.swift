//
//  RaterApp.swift
//  Rater
//
//  Created by Александр Семенов on 14.11.2023.
//

import SwiftUI

@main
struct RaterApp: App {
    
    @StateObject var appWideState = AppWideState()
    
    var body: some Scene {
        WindowGroup {
            RaterMainView()
                .environmentObject(appWideState)
        }
    }
}
