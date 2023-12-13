//
//  RaterMainView.swift
//  Rater
//
//  Created by Александр Семенов on 14.11.2023.
//

import SwiftUI

struct RaterMainView: View {
    
    @EnvironmentObject var state: AppWideState
    
    var body: some View {
        ZStack {
            RaterTabView()
            if !state.isLoggedIn {
                if !state.token {
                    LoginView()
                }
            }
            }
    }
}

#Preview {
    RaterMainView()
}
