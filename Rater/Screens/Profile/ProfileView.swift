//
//  ProfileView.swift
//  Rater
//
//  Created by Александр Семенов on 14.11.2023.
//

import SwiftUI

struct ProfileView: View {
    
    @StateObject var viewmodel = ProfileViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                if let profile = viewmodel.profile {
                    HStack {
                        Text("Profile:")
                        Text("\(profile.name)")
                        Spacer()
                        Image(systemName: "gear")
                    }
                    Spacer()
                    ProfileImages()
                    Button {
                        
                    } label: {
                        Text("Log out")
                    }
                    .foregroundColor(.red)
                    .padding(20)
                }
            }
            .task {
                do {
                    try await viewmodel.loadProfile()
                } catch let error {
                    print(error)
                }
            }
           
        }
    }
    }

#Preview {
    ProfileView()
}
