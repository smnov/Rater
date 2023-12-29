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
            NavigationView {
                ScrollView {
                    VStack {
                        if let profile = viewmodel.profile {
                            HStack(spacing: 10) {
                                Text("Profile: \(profile.name)")
                                    .fontWeight(.semibold)
                                Spacer()
                                NavigationLink(destination: SettingsView()) {
                                    Image(systemName: "gearshape.fill")
                                        .renderingMode(.original)
                                        .frame(width: 16, height: 16)
                                        .foregroundColor(.black)
                                }
                            }
                            .padding(20)
                            Spacer()
                            ProfileImages()
                        }                       
                    }
                    
                        Spacer(minLength: 20)
                        UploadPhotoView()
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
            .navigationTitle("Settings")
        }
    }

#Preview {
    ProfileView()
}
