//
//  SettingsView.swift
//  Rater
//
//  Created by Александр Семенов on 13.12.2023.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject var viewmodel = ProfileViewModel()
    @EnvironmentObject var state: AppWideState
    
    var body: some View {
        NavigationView {
            if let profile = viewmodel.profile {
                Form {
                    Section(header: Text("Profile name")) {
                        Text("\(profile.name)")
                    }
                    Section(header: Text("Email")) {
                        Text("\(profile.email)")
                    }
                }
            }
        }.navigationTitle("Profile")
        Button {
            Store.shared.deleteTokenFromStorage()
            state.isLoggedIn = false
            state.token = false
        } label: {
            Text("Log out")
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width-32, height: 48)
        }
            .background(Color(.systemRed))
            .cornerRadius(10)
            .padding(.top, 24)
        
        .task {
            do {
                try await viewmodel.loadProfile()
            } catch let error {
                print(error)
            }
        }
    }
}

#Preview {
    SettingsView()
}
