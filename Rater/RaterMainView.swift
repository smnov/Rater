//
//  RaterMainView.swift
//  Rater
//
//  Created by Александр Семенов on 14.11.2023.
//

import SwiftUI

struct RaterMainView: View {
    
    var isLoggedIn = false
    
    var body: some View {
        ZStack {
            LoginView()
            .padding()
            
            if isLoggedIn {
                RaterTabView()
            }
            }
    }
}

#Preview {
    RaterMainView()
}
